# FAB Animation

## Design/Code views
Objects created in the Design view are accessible when you register them.
Change *Home.onTap ->* to *post0.onTap ->*

```coffeescript
post0.onTap ->
  flow.showNext(Onboard)
```

## Setup global variables and register event listener

### Variables
Global variables are normally bad practice.
But when making prototypes, best practices don't always apply :) you be bad ;)

```coffeescript
isExpanded = false
icon.originZ = 0.5
postOrigin = {
	x: post0.x,
	y: post0.y
}
```

### Event listeners

Events, actions that happen in the interface. Can be triggered by user (ie: onTap, onSwipe)
or system (ie: toggles hide/show, change state, animation, changes color)

```coffeescript
add.onTap ->
	isExpanded = !isExpanded
  print 'BUTTON TAPPED, isExpanded = '+isExpanded
```

## Add functions

### Helper function
```coffeescript
chainAnimationsArray = (chain, isAuto) ->
	if chain.length > 1
		for i in [1..chain.length-1]
			chain[i-1].on Events.AnimationEnd, chain[i].start
	if isAuto then chain[0].start()
```

### FAB button functions

Define function: expands fab button color, and rotate + to x
```coffeescript
setupExpandAnimations = () ->
	smallRadius = post0.width/2
	radius = 80
	petalRadius = 20
	radialAdjustment = smallRadius - petalRadius
	step = 2*Math.PI / post0.children.length
	chain = []

	chain.push new Animation Home,
		backgroundColor: add.backgroundColor
		options:
			time: 0.25
			curve: Bezier.easeInOut
	chain.push new Animation icon,
		rotationZ: -45
		options:
			time: 0.08
			curve: Bezier.easeIn

  # Flower out

	chainAnimationsArray(chain, false)
	return chain[0]
```

Define function: rotates x back to + and contract button fill back into button
```coffeescript
setupCloseAnimations = () ->
	chain = []

  # Flower in

  chain.push new Animation icon,
		rotationZ: 0
		options:
			time: 0.08
	chain.push new Animation Home,
		backgroundColor: 'white'
		options:
			time: 0.15
			curve: Bezier.easeInOut

	chainAnimationsArray(chain, false)
	return chain[0]
```

Execute functions and return their results
```coffeescript
expandAnim = setupExpandAnimations()
closeAnim = setupCloseAnimations()
add.onTap ->
	if isExpanded then closeAnim.start() else expandAnim.start()
	isExpanded = !isExpanded
```

## Move button to the center of the page

### In setupExpandAnimations()

Add after *chain.push new Animation icon* group
```coffeescript
	chain.push new Animation post0,
		x: (Screen.width / 2) - smallRadius
		y: (Screen.height / 2) - smallRadius
```

### In setupCloseAnimations

Add before *chain.push new Animation icon,*
```coffeescript
	chain.push new Animation post0,
		x: postOrigin.x
		y: postOrigin.y
```

## Now some fun math for the flowering buttons

### In setupExpandAnimations()
Replace *# Flower out* with
```coffeescript
	dz = 0
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
```

### In setupCloseAnimations

Replace *# Flower in* with
```coffeescript
	for petal in post0.children.reverse()
		anim = new Animation petal,
			x: 0
			y: 0,
			width: 0,
			height: 0
			options:
				time: 0.05
		chain.push(anim)
```

# Onboarding
