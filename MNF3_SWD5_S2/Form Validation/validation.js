form.onsubmit = function () {
    clearErrors();
    let isValid = true;
    if (!form['Name'].value) {
        display("name-error", "name is required");
        isValid = false;
    }
    else if (form['Name'].value.length < 3) {
        display("name-error", "Name must be at least 3 characters");
        isValid = false;
    }
    else {
        let letter = /^[A-Za-z\s]+$/;
        if (!letter.test(form['Name'].value)) {
            display("name-error", "name must contain letters only");
            isValid = false;
        }
    }


    ////////////////////////////////////////////////////////////////////

    let emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-z]{2,}$/;
    if (!form['Email'].value) {
        display("email-error", "email is required");
        isValid = false;
    } else if (!emailRegex.test(form['Email'].value)) {
        display("email-error", "invalid email format");
        isValid = false;
    }

    /////////////////////////////////////////////////////////////////////////

    let PhoneRegex = /^01[0-9]{9}$/;
    if (!form["phone"].value) {
        display("phone-error", "phone is required");
        isValid = false;
    }
    else if (!PhoneRegex.test(form["phone"].value)) {
        display("phone-error", "invalid phone number");
        isValid = false;
    }

    ////////////////////////////////////////////////////////////////////////

    let passRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
    if (!form["Password"].value) {
        display("password-error", "Password is required");
        isValid = false;
    }
    else if (!passRegex.test(form["Password"].value)) {
        display("password-error", "Must At least 1 lowercase, 1 uppercase, 1 digit, min length 8");
        isValid = false;
    }

    //////////////////////////////////////////////////////////////////////////

    if (!form["ConfirmPassword"].value) {
        display("confirm-error", "Confirm Password is required");
        isValid = false;
    }
    else if (form["ConfirmPassword"].value !== form["Password"].value) {
        display("confirm-error", "Passwords do not match");
        isValid = false;
    }

    return isValid;
}