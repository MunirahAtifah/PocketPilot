// Initialize theme immediately to prevent flashing
(function() {
    const savedTheme = localStorage.getItem('pocketpilot-theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);
})();

// Toggle theme function
function toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('pocketpilot-theme', newTheme);
    
    // Trigger standard theme change event so that ChartJS can update
    const event = new CustomEvent('themeChanged', { detail: { theme: newTheme } });
    window.dispatchEvent(event);
}

// Toggle mobile menu visibility
function toggleMobileMenu() {
    const navLinks = document.getElementById('navbarLinks');
    if (navLinks) {
        navLinks.classList.toggle('active');
        const menuBtn = document.querySelector('.menu-toggle');
        if (menuBtn) {
            if (navLinks.classList.contains('active')) {
                menuBtn.innerHTML = '✕';
                menuBtn.setAttribute('aria-expanded', 'true');
            } else {
                menuBtn.innerHTML = '☰';
                menuBtn.setAttribute('aria-expanded', 'false');
            }
        }
    }
}
