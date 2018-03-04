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
	if chain.length > 2
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

  # Flower in

	chainAnimationsArray(chain, false)
	return chain[0]
```

Define function: rotates x back to + and contract button fill back into button
```coffeescript
setupCloseAnimations = () ->
	chain = []

  # Flower out

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
```

# Onboarding
