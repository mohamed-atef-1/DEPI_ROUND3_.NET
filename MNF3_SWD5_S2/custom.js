const form = document.getElementById("form");
const clearErrors = () => {
    const errors = document.getElementsByClassName("error-msg");
    for (let item of errors) {
        item.innerText = "";
    }
}
const display = (eleId, msg, color = "red") => {
    document.getElementById(eleId).innerText = msg;
    document.getElementById(eleId).style.color = color;
}