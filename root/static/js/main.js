jQuery.fn.manageFields = function() {
	var args = arguments[0] || {};
	var id = args.id;
	if ($("select[name='scanparameters." + id + ".scanner_id']").val() == '') {
		$("#scanner" + id).fadeOut(500);
	} else {
		$("#scanner" + id).fadeIn(500);
	}
	
	if ($("select[name='scanparameters." + id + ".scanner_id']").val() == '2') {
		$("#scanner" + id).fadeIn(500);
	}
}
