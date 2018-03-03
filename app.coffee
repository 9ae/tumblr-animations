# Home Screen
isExpanded = false
icon.originZ = 0.5
postOrigin = {
	x: post0.x,
	y: post0.y
}

chainAnimationsArray = (chain, isAuto) ->
	if chain.length > 2
		for i in [1..chain.length-1]
			chain[i-1].on Events.AnimationEnd, chain[i].start
	if isAuto then chain[0].start()

smallRadius = post0.width/2
expand0 = new Animation Home,
	backgroundColor: add.backgroundColor
	options:
		time: 0.25
		curve: Bezier.easeInOut
expand1 = new Animation icon,
	rotationZ: -45
	options:
		time: 0.08
		curve: Bezier.easeIn
expand2 = new Animation post0,
	x: (Screen.width / 2) - smallRadius
	y: (Screen.height / 2) - smallRadius

flower = () ->
	radius = 80
	petalRadius = 20
	radialAdjustment = smallRadius - petalRadius
	step = 2*Math.PI / post0.children.length
	dz = 0
	chain = []
	for petal in post0.children
		anim = new Animation petal,
			x: radius*Math.cos(dz) + radialAdjustment
			y: radius*Math.sin(dz) + radialAdjustment
			width: 2*petalRadius
			height: 2*petalRadius
			options:
				time: 0.15
				curve: Bezier.easeInOut
		chain.push(anim)
		dz += step
	chainAnimationsArray(chain, true)

expand0.on Events.AnimationEnd, expand1.start
expand1.on Events.AnimationEnd, expand2.start
expand2.on Events.AnimationEnd, flower

setupCloseAnimations = () ->
	chain = []
	for petal in post0.children.reverse()
		anim = new Animation petal,
			x: 0
			y: 0,
			width: 0,
			height: 0
			options:
				time: 0.05
		chain.push(anim)
	chainAnimationsArray(chain, false)
	close0 = new Animation post0,
		x: postOrigin.x
		y: postOrigin.y
	close1 = new Animation icon,
		rotationZ: 0
		options:
			time: 0.08
	close2 = new Animation Home,
		backgroundColor: 'white'
		options:
			time: 0.15
			curve: Bezier.easeInOut
	close0.on Events.AnimationEnd, close1.start
	close1.on Events.AnimationEnd, close2.start
	if chain.length > 0
		chain.pop().on Events.AnimationEnd, close0.start
		return chain[0]
	else
		return close0

closeAnim = setupCloseAnimations()
add.onTap ->
	if isExpanded then closeAnim.start() else expand0.start()
	isExpanded = !isExpanded


# Onboarding Screen
tags = []
colors = ['#009688', '#F44336', '#673AB7', '#3F51B5']
categories = (require "categories").cats
xLeft = 3
xRight = 192
dy = 150
i = 0

renderTags = () ->
	i = 0
	for tag in tagcloud.children
		if i < tags.length
			tag.html = tags[i]
			tag.backgroundColor = colors[i%colors.length]
			tag.style =
				color: 'white'
				fontSize: '11px'
				textAlign: 'center'
				borderWidth: '0'
				lineHeight: '9px'
				paddingTop: '7px'
			
		else
			tag.style =
				borderStyle: 'dashed'
				borderWidth: '1px'
				borderColor: '#898989'
			tag.html = ''
			tag.backgroundColor = 'transparent'
		i += 1

addTag = (tag) ->
	tags.push(tag)
	renderTags()

removeTag = (tag) ->
	index = tags.indexOf(tag)
	if index != -1
		tags.splice(index, 1)
		renderTags()

for cat in categories
	catLayer = new Layer
		x: if i % 2 == 0 then xLeft else xRight
		y: dy
		width: 180
		height: 180
		image: "images/onboard/"+cat.image
		saturate: 10
		brightness: 50
		name: cat.name
		borderRadius: 6
	catLayer.states =
		selected:
			brightness: 100
			saturate: 100
			blur: 12
		divide:
			blur: 0
			opacity: 1
			image: 'none'
	nameTag = new Layer
		name: 'tagName'
		html: cat.name
		x: 0
		y: 160
		width: 180
		height: 20
		backgroundColor: 'rgba(0, 0, 0, 0.6)'
		color: 'white'
		borderRadius: '0 0 6px 6px'
		style:
			fontSize: '12px'
			paddingLeft: '6px'
			lineHeight: '12px'
			paddingTop: '4px'
	catLayer.addChild nameTag
	j = 0
	for kit in cat.children
		kitten = new Layer
			width: 86
			height: 86
			x: if j % 2 == 0 then 0 else 94
			y: if Math.floor(j / 2) == 0 then 0 else 94
			image: "images/onboard/"+kit.image
			saturate: 10
			brightness: 50
			opacity: 0
			name: kit.name + '<br />'+cat.name
			borderRadius: 3
		kitten.states = 
			shown:
				opacity: 100
				saturate: 10
				brightness: 50
			selected:
				saturate: 100
				brightness: 100
		kittenName = new Layer
			html: kit.name
			x: 0
			y: 66
			width: 86
			height: 20
			backgroundColor: 'rgba(0, 0, 0, 0.6)'
			color: 'white'
			borderRadius: '0 0 3px 3px'
			style:
				fontSize: '12px'
				paddingLeft: '6px'
				lineHeight: '12px'
				paddingTop: '4px'
		kitten.onTap ->
			if this.states.current.name == 'shown'
				this.animate 'selected'
				addTag this.name 
				return
			if this.states.current.name == 'selected'
				this.animate 'shown'
				removeTag this.name
				return
		kitten.addChild kittenName
		catLayer.addChild kitten
		j += 1
	
	Onboard.addChild catLayer
	
	catLayer.onTap ->
		if this.states.current.name != 'default'
			return
		this.animate 'selected'
		thisLayer = this
		Utils.delay .8, ->
			thisLayer.stateSwitch 'divide'
			for ch in thisLayer.children
				if ch.name != 'tagName'
					ch.animate 'shown'
				else
					ch.opacity = 0
		
	
	if Math.floor(i / 2) > 0 then dy += 189
	i +=1

renderTags()

# Screen Flow
flow = new FlowComponent
flow.showNext(Onboard)

post0.onTap ->
	flow.showNext(Onboard)