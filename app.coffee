# Screen Flow
flow = new FlowComponent
flow.showNext(Home)

Home.onTap ->
	flow.showNext(Onboard)