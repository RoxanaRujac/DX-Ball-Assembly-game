# DX-BALL

A classic-style brick breaker game implemented in x86 Assembly, using low-level graphics manipulation.

![Screenshot 2025-04-15 143335](https://github.com/user-attachments/assets/4019d0c0-55eb-4985-b95c-f72a1f4f18dc)


## Features

- Move the paddle with **A** (left) and **D** (right) keys.
- Ball bounces off the top, left, and right walls.
- Missing the ball with the paddle results in **GAME OVER**.
- Breaking all 40 bricks displays a **YOU WON** message.
- Real-time paddle and ball movement with collision detection.

## Technical Details

- Written in x86 Assembly using flat memory model.
- Direct memory manipulation for pixel drawing.
- Uses `canvas.lib` for rendering.
- Custom bitmap font rendering for text display.

## Controls

- **A** – Move paddle left  
- **D** – Move paddle right

## Goal

Break all the bricks and avoid losing the ball. Good luck!
