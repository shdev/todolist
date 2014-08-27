GenericSelectView = Backbone.Marionette.ItemView.extend({
	tagName : "select",
	className : "form-control",
	modelEvents: {
		"change": "modelChange",
		"add": "modelChange",
		"remove": "modelChange",
		"fetch": "modelChange",
	},
	initialize: function(options) {
		if (!!options.optionFields) {
			this.optionFields = options.optionFields;
		} else {
			this.optionFields = { name : 'name', value : 'id'};
		}
	},
	modelChange : function () {
		var oldSelect = this.$el.val();
		this.render();
		this.$el.val(oldSelect);
	},
	render : function () {
		this.$el.empty();
		var self = this;
		this.model.each(function(aModel) {
			var elem = $('<option></option>').text(aModel.get(self.optionFields.name)).attr('value', aModel.get(self.optionFields.value));
			self.$el.append(elem);
		}); 
	},
	onRender: function(){
	}
});