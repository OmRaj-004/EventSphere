package com.eventsphere.controller;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.eventsphere.dao.BillDAO;
import com.eventsphere.dao.BookingDAO;
import com.eventsphere.dao.EventDAO;
import com.eventsphere.dao.VenueDAO;
import com.eventsphere.model.Bill;
import com.eventsphere.model.Booking;
import com.eventsphere.model.Event;
import com.eventsphere.model.User;
import com.eventsphere.model.Venue;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.awt.Color;
import java.io.IOException;

/**
 * Customer-only PDF download of a stored bill. Ownership enforced.
 */
// EventSphere project (TYBCA) - downloads the same invoice as a PDF
// file (generated with the OpenPDF library). Same ownership check
// as BillServlet: only the booking's own customer may download it.
@WebServlet("/bill.pdf")
public class PdfBillServlet extends HttpServlet {
    private final BookingDAO bookingDAO = new BookingDAO();
    private final EventDAO eventDAO = new EventDAO();
    private final VenueDAO venueDAO = new VenueDAO();
    private final BillDAO billDAO = new BillDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!user.isCustomer()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        int bookingId;
        try {
            bookingId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException | NullPointerException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        Booking booking = bookingDAO.getBookingById(bookingId);
        if (booking == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        if (booking.getCustomerId() != user.getId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        Bill bill = billDAO.getBillByBookingId(booking.getId());
        Event event = eventDAO.getEventById(booking.getEventId());
        Venue venue = venueDAO.getVenueById(booking.getVenueId());

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\""
                + (bill == null ? booking.getBookingNumber() : bill.getBillNumber()) + ".pdf\"");

        Document document = new Document();
        try {
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();
            Font title = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 20, new Color(15, 23, 42));
            Font head = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, new Color(15, 23, 42));
            Font body = FontFactory.getFont(FontFactory.HELVETICA, 11);

            Paragraph h = new Paragraph("EventSphere - INVOICE", title);
            h.setAlignment(Element.ALIGN_CENTER);
            document.add(h);
            document.add(new Paragraph("Bill: " + (bill == null ? booking.getBookingNumber() : bill.getBillNumber()), head));
            document.add(new Paragraph("Booking ref: " + booking.getBookingNumber() + "  |  Status: " + booking.getStatus(), body));
            document.add(new Paragraph("Customer: " + user.getFullName() + " <" + user.getEmail() + ">", body));
            document.add(new Paragraph("Event: " + (event == null ? "-" : event.getName() + " on " + event.getEventDate()), body));
            document.add(new Paragraph("Venue: " + (venue == null ? "-" : venue.getName() + ", " + venue.getLocation()), body));
            document.add(new Paragraph(" ", body));

            PdfPTable table = new PdfPTable(3);
            table.setWidthPercentage(100);
            addCell(table, "Description", true);
            addCell(table, "Detail", true);
            addCell(table, "Amount (Rs.)", true);
            addCell(table, "Venue hire", false);
            addCell(table, venue == null ? "-" : venue.getName(), false);
            addCell(table, String.valueOf(booking.getTotalAmount()), false);
            addCell(table, "Discount", false);
            addCell(table, "Promo", false);
            addCell(table, String.valueOf(booking.getDiscountAmount() == null ? "0" : booking.getDiscountAmount()), false);
            addCell(table, "Advance paid", false);
            addCell(table, "", false);
            addCell(table, String.valueOf(booking.getAdvancePaid() == null ? "0" : booking.getAdvancePaid()), false);
            addCell(table, "Balance due", false);
            addCell(table, "", false);
            addCell(table, bill == null ? String.valueOf(booking.getTotalAmount()) : String.valueOf(bill.getBalanceDue()), false);
            document.add(table);
            document.add(new Paragraph(" ", body));
            document.add(new Paragraph("Thank you for booking with EventSphere.", body));
        } catch (Exception e) {
            throw new IOException("PDF generation failed", e);
        } finally {
            if (document.isOpen()) {
                document.close();
            }
        }
    }

    private void addCell(PdfPTable table, String text, boolean header) {
        Font font = header
                ? FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, Color.WHITE)
                : FontFactory.getFont(FontFactory.HELVETICA, 11);
        PdfPCell cell = new PdfPCell(new Phrase(text == null ? "" : text, font));
        cell.setPadding(6);
        if (header) {
            cell.setBackgroundColor(new Color(15, 23, 42));
        }
        table.addCell(cell);
    }
}
