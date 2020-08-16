---
layout: post
title: SNAKE || React
---

The game snake is a classic in the development world. It's not overly complicated in design and should be instantly recognisable and easy to play. I chose to 'introduce' myself to React by developing a simple implementation of the classic game!

## Create React App

There's a handy command that's very useful in creating and bootstrapping React applications and it's called `create React app` it's available via npx.

```bash
npx create-react-app snake
```

Running the above creates a project space with everything we need. In fact by checking `package.json` we can see we've got several scripts defined for us. Running `yarn start` will in turn set up a development server that serves the application with hot-reloading enabled. This should make 'testing' any changes we make to our application instantly visible.

## The Snake Design

Now we've got a simple application up and running we can tear all of the basic React branding from it and start building the game. I decided to create a basic `<div classname="game-grid ></div>` to house the snake grid itself with some simple css.

```css
.game-grid {
  position: relative;
  margin: 50px auto;
  width: 450px;
  height: 450px;
  border: 2px solid #000;
}
```

Inside this game grid I'd render individual snake segments defined by a basic cooridnate system. In fact the React component ended up looking fairly simple.

```jsx
export default props => {
  return (
    <div>
      {props.snakeSegments.map((segment, i) => {
        const style = {
          left: `${segment[0]}%`,
          top: `${segment[1]}%`
        };
        return <div className="snake-segment" key={i} style={style}></div>;
      })}
   </div>
  );
};
```

I'd pass in a list of 'snake segments' that would be mapped to a 'point' on our grid. The component accesses the segments via properties passed down from the parent component. I also chose to add two other components called `Food` and `Score` that would be used to render in the snakes food and the players score.

## Snake Logic

With the components set up we can begin with the game. Essentially snake can be modelled with a simple game loop, get the user input, update the game state and draw the game. So after adding a key listener to our parent component we need to update the game state and draw the game. Using `componentDidMount` we can perform so logic as soon as our component is ready to do so.

```jsx
  componentDidMount() {
    document.onkeydown = this.onKeyDown;
    setInterval(this.moveSnake, 50);
  }
  ```

We set our key listener and call the setInterval method with our game state update (moveSnake) and an update interval, in this case 50ms or 20 times a second. When a user hits an arrow key we map it to a property in our games state called direction. We then deterimine which direction the snake should move by calculating the new snake head posistion adding it to our existing snake array and removing the tail piece (after all snake is just a constantly shifting array).

### Eating Food

Of course our snake needs to eat! Food is set to spawn at random coordinates, when the snake's head collides with the food we add the food to the end of the snake and update the score.

### Collision Detection

There are two conditions we need to check on every game update:

1. Did the snake hit a boundary?
2. Did the snake hit itself?

These can both be driven entirely by the snake's head, i.e did it's cooridnates intersect with a wall or coordinates within it's own body.

### Putting it all together

The final result then is indeed reminsicent of a classic game of snake. The logic at this stage is not very well optimised and I've implemented using Reacts lifecycle method of `componentDidUpdate` too. This function is called upon any updates to the component and using this in conjuction with our already setup game loop is unwise. The game however seems to behave as expected with the one caveat that new food pieces are able to spawn inside the snake itself... hmmm. I suspect this is a side effect of the issue metnioned above but as an introductory piece to react I'm sure it can only get better.

Code availble [here](https://github.com/sgregory8/snake)
