
function revealModal(divID)
{
    window.onscroll = function () {
        document.getElementById(divID).style.top = document.body.scrollTop;
    };
    document.getElementById(divID).style.display = "block";
    document.getElementById(divID).style.top = document.body.scrollTop;
}

function hideModal(divID)
{
    document.getElementById(divID).style.display = "none";
}

function updateField(filefield, number) {
    var name = document.getElementById( "name" + number );
    if (! name.value && filefield.value) {
        var temp = filefield.value;
        temp = temp.replace(/.*[\\\/]/, "");
        temp = temp.replace(/\..*$/, "");
        name.value = temp;
    }
}

