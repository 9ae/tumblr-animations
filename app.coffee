isExpanded = false
icon.originZ = 0.5
postOrigin = {
	x: post0.x,
	y: post0.y
}

# Helper Functions
chainAnimationsArray = (chain, isAuto) ->
	if chain.length > 2
		for i in [1..chain.length-1]
			chain[i-1].on Events.AnimationEnd, chain[i].start
	if isAuto then chain[0].start()

# Expand Animations

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

# Close Animations
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