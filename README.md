# Post Animation

## Change *Home.onTap ->* to *post0.onTap ->*

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

### Event listener

Events, actions that happen in the interface. Can be triggered by user (ie: onTap, onSwipe)
or system (ie: toggles hide/show, change state, animation, changes color)

```coffeescript
add.onTap ->
	isExpanded = !isExpanded
  print 'BUTTON TAPPED, isExpanded = '+isExpanded
```

# Onboarding
