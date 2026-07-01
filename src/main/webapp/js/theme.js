// PocketPilot Theme Selector & Loader Script
(function () {
    // 1. Immediately apply the saved theme to prevent white flash
    const savedTheme = localStorage.getItem('pocketpilot-theme') || 'dark'; // Dark theme is default
    document.documentElement.className = savedTheme + '-theme';

    // 2. Append the floating theme switch once the DOM is fully parsed
    document.addEventListener('DOMContentLoaded', function () {
        const toggleBtn = document.createElement('button');
        toggleBtn.className = 'theme-float-toggle';
        toggleBtn.id = 'themeFloatToggle';
        toggleBtn.setAttribute('aria-label', 'Toggle light/dark theme');
        toggleBtn.textContent = savedTheme === 'light' ? 'Dark Mode' : 'Light Mode';

        // Add styling for the floating capsule button dynamically
        const style = document.createElement('style');
        style.textContent = `
            .theme-float-toggle {
                position: fixed;
                bottom: 25px;
                right: 25px;
                padding: 10px 18px;
                border-radius: 30px;
                background: var(--accent, #9d4edd);
                color: #ffffff;
                border: 1px solid var(--border-color);
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.15);
                cursor: pointer;
                font-size: 13px;
                font-weight: 600;
                font-family: 'Outfit', sans-serif;
                z-index: 10000;
                transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275), background-color 0.3s, color 0.3s;
            }
            .theme-float-toggle:hover {
                transform: scale(1.05);
                background: var(--accent-light, #c77dff);
            }
            .theme-float-toggle:active {
                transform: scale(0.95);
            }
        `;
        document.head.appendChild(style);
        document.body.appendChild(toggleBtn);

        // 3. Toggle button event click handler
        toggleBtn.addEventListener('click', function () {
            const isDark = document.documentElement.classList.contains('dark-theme');
            const newTheme = isDark ? 'light' : 'dark';
            
            document.documentElement.className = newTheme + '-theme';
            localStorage.setItem('pocketpilot-theme', newTheme);
            toggleBtn.textContent = newTheme === 'light' ? 'Dark Mode' : 'Light Mode';
        });

        // 4. Responsive Navbar Setup
        const navbar = document.querySelector('.navbar');
        if (navbar) {
            const menuToggle = document.createElement('button');
            menuToggle.className = 'menu-toggle';
            menuToggle.id = 'menuToggle';
            menuToggle.setAttribute('aria-label', 'Toggle navigation menu');
            menuToggle.innerHTML = '☰ Menu';
            
            const navLinks = document.createElement('div');
            navLinks.className = 'nav-links';
            navLinks.id = 'navLinks';
            
            const children = Array.from(navbar.children);
            children.forEach(child => {
                navLinks.appendChild(child);
            });
            
            navbar.appendChild(menuToggle);
            navbar.appendChild(navLinks);
            
            menuToggle.addEventListener('click', function () {
                const isOpen = navLinks.classList.contains('active');
                if (isOpen) {
                    navLinks.classList.remove('active');
                    menuToggle.innerHTML = '☰ Menu';
                } else {
                    navLinks.classList.add('active');
                    menuToggle.innerHTML = '✕ Close';
                }
            });
        }
    });
})();
