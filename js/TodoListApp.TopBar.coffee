App.module 'TodoListApp.TopBar', (TopBar, App, Backbone, Marionette, $, _) ->

	
	class TopBarView extends Marionette.LayoutView
		template : _.template """
			<nav class="navbar navbar-default" role="navigation">
				<div class="container">
					<!-- Brand and toggle get grouped for better mobile display -->
					<div class="navbar-header">
						<a class="navbar-brand" href="#"></a>
						<p class="navbar-text"><button type="button" class="btn btn-success"><i class="fa fa-refresh fa-spin"></i></button> Signed in as <a href="#" class="navbar-link">Mark Otto</a></p>

					</div>
				</div><!-- /.container-fluid -->
			</nav>
		"""
	
	App.reqres.setHandler "TodoListApp:class:TopBarView", () ->
		TopBarView
	
	App.mainRegion.on 'before:show', (view) -> 
		console.debug "App.mainregion.on 'before:show'"
		console.debug view
		###
		TODO check with instanceof
		###
		TopBar.mainView = new TopBarView()
		view.topBar.show(TopBar.mainView)