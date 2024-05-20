document.addEventListener("DOMContentLoaded", () => {
    const form = document.getElementById("signupForm");

    form.addEventListener("submit", (event) => {
        let isValid = true;

        // Name validation
        const name = document.getElementById("name").value.trim();
        if (name === "") {
            alert("Name is required");
            isValid = false;
        }

        // Email validation
        const email = document.getElementById("mail").value.trim();
        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailPattern.test(email)) {
            alert("Please enter a valid email address");
            isValid = false;
        }

        // Password validation
        const password = document.getElementById("password").value.trim();
        if (password.length < 8) {
            alert("Password must be at least 8 characters long");
            isValid = false;
        }

        // Age validation
        const ageUnder13 = document.getElementById("under_13").checked;
        const ageOver13 = document.getElementById("over_13").checked;
        if (!ageUnder13 && !ageOver13) {
            alert("Please select an age group");
            isValid = false;
        }

        // Bio validation
        const bio = document.getElementById("bio").value.trim();
        if (bio.length < 1 || bio.length > 50) {
            alert("Bio must be between 1 and 50 characters long");
            isValid = false;
        }

        // Job role validation
        const job = document.getElementById("job").value;
        if (job === "") {
            alert("Please select a job role");
            isValid = false;
        }

        if (!isValid) {
            event.preventDefault(); // Prevent form submission if validation fails
        } else {
            event.preventDefault(); // Prevent form submission to show the success message
            document.getElementById("successMessage").style.display = "block";
        }
    });
});
