$(function() {

    $('#side-menu').metisMenu();

});

//Loads the correct sidebar on window load,
//collapses the sidebar on window resize.
// Sets the min-height of #page-wrapper to window size
$(function() {
    $(window).bind("load resize", function() {
        topOffset = 50;
        width = (this.window.innerWidth > 0) ? this.window.innerWidth : this.screen.width;
        if (width < 768) {
            $('div.navbar-collapse').addClass('collapse')
            topOffset = 100; // 2-row-menu
        } else {
            $('div.navbar-collapse').removeClass('collapse')
        }

        height = (this.window.innerHeight > 0) ? this.window.innerHeight : this.screen.height;
        height = height - topOffset;
        if (height < 1) height = 1;
        if (height > topOffset) {
            $("#page-wrapper").css("min-height", (height) + "px");
        }
    })
})

function display(el, active) {
	document.getElementById(el).style.display = active ? 'block' : 'none';
}

function sendFile(file) {
    var uri = "/admincp/uploader.php?install_template=1";
    var xhr = new XMLHttpRequest();
    var fd = new FormData();

    xhr.open("POST", uri, true);
    xhr.onreadystatechange = function() {
	if (oXHR.readyState === 4) {
		if(xhr.status == 200) {
	    		// Handle response.
	    		alert(xhr.responseText); // handle response.
		} else {
	    		alert(`Error: ${xhr.statusText}`);
		}
	}

	display('newTemplate', true);
	display('uploader', false);
	document.location.reload(true);
    };
    fd.append('templatefile', file);
    // Initiate a multipart/form-data upload
    xhr.send(fd);
}

function handleFiles(filesArray) {
	display('newTemplate', false);
	display('uploader', true);

	for (var i=0; i<filesArray.length; i++) {
		sendFile(filesArray[i]);
	}
}
