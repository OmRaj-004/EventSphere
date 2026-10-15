// EventSphere - Main JavaScript File

// Form Validation
function validateEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

function validatePassword(password) {
    return password && password.length >= 6;
}

function validateForm() {
    const fullName = document.getElementById('fullName');
    const email = document.getElementById('email');
    const password = document.getElementById('password');
    const confirmPassword = document.getElementById('confirmPassword');
    
    let isValid = true;
    
    if (fullName && !fullName.value.trim()) {
        showError('Full name is required');
        isValid = false;
    }
    
    if (email && !validateEmail(email.value)) {
        showError('Invalid email format');
        isValid = false;
    }
    
    if (password && !validatePassword(password.value)) {
        showError('Password must be at least 6 characters');
        isValid = false;
    }
    
    if (confirmPassword && password && password.value !== confirmPassword.value) {
        showError('Passwords do not match');
        isValid = false;
    }
    
    return isValid;
}

function validateLoginForm(form) {
    const emailInput = form ? form.querySelector('input[name="email"]') : null;
    const passwordInput = form ? form.querySelector('input[name="password"]') : null;
    
    let isValid = true;
    
    if (emailInput && !validateEmail(emailInput.value)) {
        showError('Invalid email format');
        isValid = false;
    }
    
    if (passwordInput && !passwordInput.value.trim()) {
        showError('Password is required');
        isValid = false;
    }
    
    return isValid;
}

function showToast(message, type) {
    let container = document.getElementById('esToastContainer');
    if (!container) {
        document.body.insertAdjacentHTML('beforeend', '<div id="esToastContainer" class="es-toast-container" aria-live="polite"></div>');
        container = document.getElementById('esToastContainer');
    }
    const toast = document.createElement('div');
    toast.className = 'toast ' + (type === 'error' ? 'toast-error' : 'toast-success');
    toast.textContent = message;
    container.appendChild(toast);
    setTimeout(() => toast.classList.add('hide'), 4000);
    setTimeout(() => toast.remove(), 4500);
}

// Display Error Messages
function showError(message) {
    const errorDiv = document.getElementById('error-message');
    if (errorDiv) {
        errorDiv.textContent = message;
        errorDiv.style.display = 'block';
    } else {
        showToast(message, 'error');
    }
}

function clearError() {
    const errorDiv = document.getElementById('error-message');
    if (errorDiv) {
        errorDiv.textContent = '';
        errorDiv.style.display = 'none';
    }
}

// Search Venues
function searchVenues(event) {
    if (event) {
        event.preventDefault();
    }
    
    const eventType = document.getElementById('eventType')?.value || '';
    const maxCapacity = document.getElementById('maxCapacity')?.value || '';
    const priceRange = document.getElementById('priceRange')?.value || '';
    
    // Validate numeric inputs
    if (maxCapacity && (isNaN(maxCapacity) || maxCapacity < 1)) {
        showError('Please enter a valid capacity (minimum 1)');
        return;
    }
    if (priceRange && (isNaN(priceRange) || priceRange < 0)) {
        showError('Please enter a valid price (0 or higher)');
        return;
    }
    
    const params = new URLSearchParams();
    if (eventType) params.append('eventType', eventType);
    if (maxCapacity) params.append('maxCapacity', maxCapacity);
    if (priceRange) params.append('priceRange', priceRange);
    
    const form = event?.target;
    const action = form?.getAttribute('action') || getVenuesUrl();
    window.location.href = action + '?' + params.toString();
}

function getVenuesUrl() {
    const path = window.location.pathname;
    // Already on /venues (e.g. /EventSphere/venues) -> use it as-is, never append again
    if (/(^|\/)venues\/?$/.test(path)) {
        return path;
    }
    // On home page (/EventSphere/ or /EventSphere/index.jsp) -> go to sibling /venues
    return path.replace(/\/(index\.jsp)?$/, '') + '/venues';
}

function updateMultiBooking() {
    const boxes = document.querySelectorAll('.venue-pick-box:checked');
    const btn = document.getElementById('multiBookBtn');
    if (btn) {
        btn.style.display = boxes.length > 1 ? '' : 'none';
        btn.textContent = 'Book Selected Together (' + boxes.length + ')';
    }
}

function submitMultiBooking(event) {
    const boxes = document.querySelectorAll('.venue-pick-box:checked');
    if (boxes.length < 2) {
        showError('Select at least two venues to book together');
        if (event) event.preventDefault();
        return false;
    }
    const ids = Array.from(boxes).map(b => b.value).join(',');
    document.getElementById('multiVenueIds').value = ids;
    return true;
}

function clearFilters() {
    const eventType = document.getElementById('eventType');
    const maxCapacity = document.getElementById('maxCapacity');
    const priceRange = document.getElementById('priceRange');
    const eventDate = document.getElementById('eventDate');
    
    if (eventType) eventType.value = '';
    if (maxCapacity) maxCapacity.value = '';
    if (priceRange) priceRange.value = '';
    if (eventDate) eventDate.value = '';
    
    const form = eventType?.closest('form');
    const action = form?.getAttribute('action') || getVenuesUrl();
    window.location.href = action;
}

function esSetFieldError(input, message) {
    if (!input) return;
    input.classList.add('es-invalid');
    input.setAttribute('aria-invalid', 'true');
    let err = input.parentElement.querySelector('.field-error');
    if (!err) {
        err = document.createElement('small');
        err.className = 'field-error';
        input.insertAdjacentElement('afterend', err);
    }
    err.textContent = message;
}

function esClearFieldError(input) {
    if (!input) return;
    input.classList.remove('es-invalid');
    input.removeAttribute('aria-invalid');
    const err = input.parentElement.querySelector('.field-error');
    if (err) err.remove();
}

function validateBookingForm(form) {
    const date = form?.querySelector('[name="bookingDate"]');
    const start = form?.querySelector('[name="startTime"]');
    const end = form?.querySelector('[name="endTime"]');
    const guestsEl = form?.querySelector('[name="expectedGuests"]');
    const guests = Number(guestsEl?.value);
    const today = new Date().toISOString().split('T')[0];
    let isValid = true;
    if (!date || !date.value || date.value < today) {
        esSetFieldError(date, 'Please select a future booking date');
        isValid = false;
    } else {
        esClearFieldError(date);
    }
    if (!start || !start.value || !end || !end.value || start.value >= end.value) {
        esSetFieldError(start, 'Start time must be before end time');
        esSetFieldError(end, 'End time must be after start time');
        isValid = false;
    } else {
        esClearFieldError(start);
        esClearFieldError(end);
    }
    const maxGuests = guestsEl && guestsEl.max ? Number(guestsEl.max) : 0;
    if (!Number.isInteger(guests) || guests < 1) {
        esSetFieldError(guestsEl, 'Expected guests must be greater than zero');
        isValid = false;
    } else if (maxGuests > 0 && guests > maxGuests) {
        esSetFieldError(guestsEl, 'Exceeds venue capacity (' + maxGuests + ')');
        isValid = false;
    } else {
        esClearFieldError(guestsEl);
    }
    if (!isValid) {
        showError('Please fix the highlighted fields');
        const firstBad = form.querySelector('.es-invalid');
        if (firstBad) firstBad.focus();
    }
    return isValid;
}

// Live price estimate on the booking form (hourly rate x duration)
function esUpdatePriceEstimate() {
    const form = document.getElementById('bookingForm');
    const box = document.getElementById('priceEstimate');
    if (!form || !box) return;
    const rate = Number(form.dataset.hourlyRate);
    const start = form.querySelector('[name="startTime"]')?.value;
    const end = form.querySelector('[name="endTime"]')?.value;
    if (!rate || !start || !end || start >= end) {
        box.hidden = true;
        return;
    }
    const toMin = (t) => { const p = t.split(':'); return Number(p[0]) * 60 + Number(p[1]); };
    const hours = (toMin(end) - toMin(start)) / 60;
    if (!(hours > 0)) {
        box.hidden = true;
        return;
    }
    box.hidden = false;
    box.textContent = 'Estimated total: ' + formatCurrency(Math.round(rate * hours)) +
        ' for ' + (Number.isInteger(hours) ? hours : hours.toFixed(1)) + ' hr' +
        (hours === 1 ? '' : 's') + ' (' + formatCurrency(rate) + '/hr)';
}

// Date Picker Setup
function initializeDatePicker() {
    const dateInputs = document.querySelectorAll('input[type="date"]');
    const today = new Date().toISOString().split('T')[0];
    dateInputs.forEach(input => {
        if (!input.hasAttribute('min')) {
            input.setAttribute('min', today);
        }
    });
}

// Confirm Action (styled in-page modal — replaces native confirm() dialogs)
function esEnsureConfirmModal() {
    if (document.getElementById('esConfirmOverlay')) return;
    document.body.insertAdjacentHTML('beforeend',
        '<div id="esConfirmOverlay" class="es-confirm-overlay" hidden>' +
        '<div class="es-confirm-dialog" role="alertdialog" aria-modal="true" aria-labelledby="esConfirmTitle">' +
        '<div class="es-confirm-title" id="esConfirmTitle">Please confirm</div>' +
        '<p class="es-confirm-message" id="esConfirmMessage"></p>' +
        '<div class="es-confirm-actions">' +
        '<button type="button" class="btn btn-outline" id="esConfirmCancel">Cancel</button>' +
        '<button type="button" class="btn btn-danger" id="esConfirmOk">Confirm</button>' +
        '</div></div></div>');
}

function esShowConfirm(message) {
    esEnsureConfirmModal();
    const overlay = document.getElementById('esConfirmOverlay');
    const msgEl = document.getElementById('esConfirmMessage');
    const okBtn = document.getElementById('esConfirmOk');
    const cancelBtn = document.getElementById('esConfirmCancel');
    msgEl.textContent = message || 'Are you sure?';
    overlay.hidden = false;
    document.body.classList.add('es-modal-open');
    okBtn.focus();
    return new Promise((resolve) => {
        const done = (value) => {
            overlay.hidden = true;
            document.body.classList.remove('es-modal-open');
            okBtn.onclick = null;
            cancelBtn.onclick = null;
            overlay.onclick = null;
            document.removeEventListener('keydown', onKey);
            resolve(value);
        };
        const onKey = (e) => { if (e.key === 'Escape') done(false); };
        okBtn.onclick = () => done(true);
        cancelBtn.onclick = () => done(false);
        overlay.onclick = (e) => { if (e.target === overlay) done(false); };
        document.addEventListener('keydown', onKey);
    });
}

function esResetFormButtons(form) {
    if (!form) return;
    form.querySelectorAll('button[type="submit"], input[type="submit"]').forEach((btn) => {
        setLoadingState(btn, false);
    });
}

function esInterceptConfirm(message) {
    const evt = (typeof window.event !== 'undefined') ? window.event : null;
    const form = (evt && evt.target instanceof HTMLFormElement) ? evt.target : null;
    if (evt && evt.preventDefault) evt.preventDefault();
    esShowConfirm(message).then((ok) => {
        if (ok && form) {
            form.submit();
        } else if (form) {
            esResetFormButtons(form);
        }
    });
    return false;
}

function confirmDelete(message) {
    return esInterceptConfirm(message || 'Are you sure you want to delete this?');
}

function confirmAction(message) {
    return esInterceptConfirm(message || 'Are you sure?');
}

// Format Currency
function formatCurrency(amount) {
    return new Intl.NumberFormat('en-IN', {
        style: 'currency',
        currency: 'INR'
    }).format(amount);
}

// Format Date
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

// Toggle Element Visibility
function toggleElement(elementId) {
    const element = document.getElementById(elementId);
    if (element) {
        element.style.display = element.style.display === 'none' ? 'block' : 'none';
    }
}

// Logout with confirmation
function logout() {
    esShowConfirm('Are you sure you want to logout?').then((ok) => {
        if (!ok) return;
        const ctx = window.location.pathname.split('/')[1] || '';
        const logoutForm = document.querySelector('form[action$="/logout"]');
        if (logoutForm) {
            logoutForm.submit();
        } else {
            window.location.href = '/' + ctx + '/login?logout=true';
        }
    });
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    initializeDatePicker();
    
    // Clear error messages when user types in the relevant field
    const inputs = document.querySelectorAll('input, textarea, select');
    inputs.forEach(input => {
        input.addEventListener('input', clearError);
    });
    
    // Add loading states to forms
    const forms = document.querySelectorAll('form[onsubmit]');
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            const submitBtn = form.querySelector('button[type="submit"], input[type="submit"]');
            if (submitBtn && !submitBtn.disabled) {
                // Small delay to allow validation to run first
                setTimeout(() => setLoadingState(submitBtn, true), 0);
            }
        });
    });
    
    // Navbar scroll effect
    const navbar = document.querySelector('.navbar');
    if (navbar) {
        const handleScroll = () => {
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        };
        window.addEventListener('scroll', handleScroll, { passive: true });
        // Initial check
        handleScroll();
    }
});

// Close alert messages
document.addEventListener('DOMContentLoaded', function() {
    const closeButtons = document.querySelectorAll('.alert-close');
    closeButtons.forEach(button => {
        button.addEventListener('click', function() {
            this.parentElement.style.display = 'none';
        });
    });
});

// Loading State Management
function setLoadingState(button, isLoading) {
    if (!button) return;
    if (isLoading) {
        button.disabled = true;
        button.dataset.originalText = button.innerHTML;
        button.innerHTML = '<span class="spinner"></span> Processing...';
    } else {
        button.disabled = false;
        if (button.dataset.originalText) {
            button.innerHTML = button.dataset.originalText;
        }
    }
}

// Venue image lightbox (venue details page)
function esOpenLightbox(src, alt) {
    let overlay = document.getElementById('esLightbox');
    if (!overlay) {
        document.body.insertAdjacentHTML('beforeend',
            '<div id="esLightbox" class="es-lightbox" hidden>' +
            '<img id="esLightboxImg" src="" alt="Venue image enlarged">' +
            '<button type="button" class="es-lightbox-close" aria-label="Close image viewer">✕</button></div>');
        overlay = document.getElementById('esLightbox');
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay || e.target.classList.contains('es-lightbox-close')) {
                overlay.hidden = true;
                document.body.classList.remove('es-modal-open');
            }
        });
        document.addEventListener('keydown', (e) => {
            const lb = document.getElementById('esLightbox');
            if (e.key === 'Escape' && lb && !lb.hidden) {
                lb.hidden = true;
                document.body.classList.remove('es-modal-open');
            }
        });
    }
    const img = document.getElementById('esLightboxImg');
    img.src = src;
    img.alt = alt || 'Venue image enlarged';
    overlay.hidden = false;
    document.body.classList.add('es-modal-open');
}

// AJAX venue search (progressive enhancement; falls back to full navigation)
function esAjaxVenueSearch(event) {
    event.preventDefault();
    const form = event.target.closest ? event.target.closest('form') : event.target;
    const params = new URLSearchParams();
    const eventType = document.getElementById('eventType')?.value || '';
    const maxCapacity = document.getElementById('maxCapacity')?.value || '';
    const priceRange = document.getElementById('priceRange')?.value || '';
    if (maxCapacity && (isNaN(maxCapacity) || maxCapacity < 1)) {
        showError('Please enter a valid capacity (minimum 1)');
        return;
    }
    if (priceRange && (isNaN(priceRange) || priceRange < 0)) {
        showError('Please enter a valid price (0 or higher)');
        return;
    }
    if (eventType) params.append('eventType', eventType);
    if (maxCapacity) params.append('maxCapacity', maxCapacity);
    if (priceRange) params.append('priceRange', priceRange);
    const action = form?.getAttribute('action') || getVenuesUrl();
    const url = action + (params.toString() ? '?' + params.toString() : '');
    const results = document.getElementById('venueResults');
    if (!results) {
        window.location.href = url;
        return;
    }
    results.innerHTML = '<div class="grid grid-3" aria-hidden="true">' +
        '<div class="card venue-card"><div class="skeleton skeleton-img"></div><div class="skeleton skeleton-line"></div><div class="skeleton skeleton-line"></div></div>' +
        '<div class="card venue-card"><div class="skeleton skeleton-img"></div><div class="skeleton skeleton-line"></div><div class="skeleton skeleton-line"></div></div>' +
        '<div class="card venue-card"><div class="skeleton skeleton-img"></div><div class="skeleton skeleton-line"></div><div class="skeleton skeleton-line"></div></div></div>';
    fetch(url, { headers: { 'X-Requested-With': 'fetch' } })
        .then((res) => {
            if (!res.ok) throw new Error('Search failed');
            return res.text();
        })
        .then((html) => {
            const doc = new DOMParser().parseFromString(html, 'text/html');
            const fresh = doc.getElementById('venueResults');
            if (!fresh) throw new Error('Unexpected response');
            results.innerHTML = fresh.innerHTML;
            try { window.history.pushState({}, '', url); } catch (e) { /* ignore */ }
        })
        .catch(() => {
            window.location.href = url;
        });
}

// Page-specific interactive wiring
document.addEventListener('DOMContentLoaded', function() {
    // Live price estimate + per-field validation on the booking form
    const bookingForm = document.getElementById('bookingForm');
    if (bookingForm) {
        ['bookingDate', 'startTime', 'endTime', 'expectedGuests'].forEach((name) => {
            const input = bookingForm.querySelector('[name="' + name + '"]');
            if (!input) return;
            input.addEventListener('input', () => {
                esClearFieldError(input);
                esUpdatePriceEstimate();
            });
            input.addEventListener('change', esUpdatePriceEstimate);
            input.addEventListener('blur', () => {
                validateBookingForm(bookingForm);
            });
        });
        esUpdatePriceEstimate();
    }

    // Lightbox for the venue details main image and review photos
    if (document.querySelector('.cal-grid')) {
        const mainImg = document.querySelector('main .grid-2 img.venue-image');
        if (mainImg) {
            mainImg.classList.add('zoomable');
            mainImg.addEventListener('click', () => esOpenLightbox(mainImg.src, mainImg.alt));
        }
        document.querySelectorAll('.feedback-photo').forEach((img) => {
            img.classList.add('zoomable');
            img.addEventListener('click', () => esOpenLightbox(img.src, img.alt));
        });
    }

    // AJAX search on the venues browse page
    const venueFilterForm = document.getElementById('venueFilterForm');
    if (venueFilterForm) {
        venueFilterForm.addEventListener('submit', esAjaxVenueSearch);
    }
});
