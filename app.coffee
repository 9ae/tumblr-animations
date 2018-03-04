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


# ONBOARDING SCREEN

# Import files
categories = (require "categories").cats

# Screen variables
tags = []
colors = ['#009688', '#F44336', '#673AB7', '#3F51B5']
CATEGORY_SPACING = 9
XLEFT = 3
CATEGORY_WIDTH = 180
XRIGHT = XLEFT + CATEGORY_WIDTH + CATEGORY_SPACING
SUBCATEGORY_WIDTH = 86
SUBCATEGORY_OFFSET = 94
DIM_SAT = 10
DIM_BRIGHT = 50
TAG_TEXT_HEIGHT = 20
BORDER_RADIUS_CATEGORY = 6
BORDER_RADIUS_SUBCAT = 3


# Tag functions
renderTags = () ->
	i = 0
	for tag in tagcloud.children
		if i < tags.length
			tag.html = tags[i]
			tag.backgroundColor = colors[i%colors.length]
			tag.stateSwitch('filled')
			
		else
			tag.stateSwitch('default')
		i += 1

addTag = (tag) ->
	tags.push(tag)
	renderTags()

removeTag = (tag) ->
	index = tags.indexOf(tag)
	if index != -1
		tags.splice(index, 1)
		renderTags()

# Initialize Tags
i = 0
dy = 150
for tagLayer in tagcloud.children
	tagLayer.states.add
		default:
			html: ''
			backgroundColor: 'transparent'
			style:
				borderStyle: 'dashed'
				borderWidth: '1px'
				borderColor: '#dcdcdc'
		filled:
			style:
				color: 'white'
				fontSize: '11px'
				textAlign: 'center'
				borderWidth: '0'
				lineHeight: '1.0em'
				paddingTop: '10px'

# Initialize Categories
for cat in categories
	categoryGroup = new Layer
		x: if i % 2 == 0 then XLEFT else XRIGHT
		y: dy
		width: CATEGORY_WIDTH
		height: CATEGORY_WIDTH
		backgroundColor: 'transparent'
	
	# Category Setup
	catLayer = new Layer
		x: 0
		y: 0
		width: CATEGORY_WIDTH
		height: CATEGORY_WIDTH
		image: "images/onboard/"+cat.image
		saturate: DIM_SAT
		brightness: DIM_BRIGHT
		name: cat.name
		borderRadius: BORDER_RADIUS_CATEGORY
	catLayer.states =
		unselected:
			width: SUBCATEGORY_WIDTH
			height: SUBCATEGORY_WIDTH
			x: SUBCATEGORY_OFFSET
			y: SUBCATEGORY_OFFSET
			saturate: DIM_SAT
			brightness: DIM_BRIGHT
			borderRadius: BORDER_RADIUS_SUBCAT
		selected:
			width: SUBCATEGORY_WIDTH
			height: SUBCATEGORY_WIDTH
			x: SUBCATEGORY_OFFSET
			y: SUBCATEGORY_OFFSET
			brightness: 100
			saturate: 100
			borderRadius: BORDER_RADIUS_SUBCAT
	catName = new Layer
		name: 'tagName'
		html: cat.name
		backgroundColor: 'transparent'
		color: 'white'
		style:
			paddingTop: '6px'
			paddingLeft: '6px'
			fontSize: '32px'
	catName.states =
		small:
			x: 0
			y: SUBCATEGORY_WIDTH - TAG_TEXT_HEIGHT
			width: SUBCATEGORY_WIDTH
			height: TAG_TEXT_HEIGHT
			backgroundColor: 'rgba(0, 0, 0, 0.6)'
			borderRadius: '0 0 3px 3px'
			style:
				fontSize: '12px'
				paddingLeft: '6px'
				lineHeight: '12px'
				paddingTop: '4px'
			animationOptions:
				time: 0.05

	catLayer.addChild catName
	
	catLayer.on Events.StateSwitchEnd, ->
		if this.states.previous.name == 'default'
			for subcat in this.parent.children
				if subcat == this
					continue
				subcat.animate 'unselected'
	
	catLayer.onTap ->
		switch this.states.current.name
			when 'default'
				labels = this.childrenWithName 'tagName'
				if labels.length == 1
					labels[0].animate 'small'
					this.animate 'unselected'
					labels[0].html = 'All '+labels[0].html
			when 'unselected'
				addTag(this.name)
				this.animate 'selected'
			when 'selected'
				removeTag(this.name)
				this.animate 'unselected'
	
	# Sub category setup
	j = 0
	for subcat in cat.children
		subcatLayer = new Layer
			width: SUBCATEGORY_WIDTH
			height: SUBCATEGORY_WIDTH
			x: if j % 2 == 0 then 0 else SUBCATEGORY_OFFSET
			y: if Math.floor(j / 2) == 0 then 0 else SUBCATEGORY_OFFSET
			image: "images/onboard/"+subcat.image
			saturate: DIM_SAT
			brightness: DIM_BRIGHT
			opacity: 0
			name: subcat.name
			borderRadius: BORDER_RADIUS_SUBCAT
		subcatLayer.states.add
			unselected:
				opacity: 1
				saturate: DIM_SAT
				brightness: DIM_BRIGHT
			selected:
				opacity: 1
				saturate: 100
				brightness: 100
		subcatName = new Layer
			x: 0
			y: SUBCATEGORY_WIDTH - TAG_TEXT_HEIGHT
			width: SUBCATEGORY_WIDTH
			height: TAG_TEXT_HEIGHT
			name: 'tagName'
			html: subcat.name
			color: 'white'
			backgroundColor: 'rgba(0, 0, 0, 0.6)'
			borderRadius: '0 0 3px 3px'
			style:
				fontSize: '12px'
				paddingLeft: '6px'
				lineHeight: '12px'
				paddingTop: '4px'
		subcatLayer.addChild subcatName
		categoryGroup.addChild subcatLayer
		
		subcatLayer.onTap ->
			switch this.states.current.name
				when 'unselected'
					addTag(this.name)
					this.animate 'selected'
				when 'selected'
					removeTag(this.name)
					this.animate 'unselected'
		j += 1
	
	categoryGroup.addChild catLayer
	Onboard.addChild categoryGroup
	if Math.floor(i / 2) > 0 then dy += (CATEGORY_WIDTH + CATEGORY_SPACING)
	i +=1

renderTags()

# Screen Flow
flow = new FlowComponent
flow.showNext(Home)

post0.onTap ->
	flow.showNext(Onboard)