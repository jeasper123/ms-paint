// Converted from Processing (Java) to p5.js
let brushLayer;
let cursorLayer;

let brushX, brushY;
let cursorX, cursorY;
let brushSpeed = 2.5;
let avoidanceRadius = 100;
let randomAngle;
let centerPullStrength = 6;
let edgeRepulsionStrength = 2;

let cursorGrab;
let cursorIdle;
let brushIcon;
let menuImage;

let brushIconSize = 30;
let showWarning = false;
let warningTimer = 0;
let warningDuration = 120;

function preload() {
  cursorGrab = loadImage("cursor-grab.png");
  cursorIdle = loadImage("cursor.png");
  brushIcon = loadImage("brush.png");
  menuImage = loadImage("menu.png");
}

function setup() {
  createCanvas(900, 700, WEBGL);
  noCursor();

  brushLayer = createGraphics(900, 700);
  brushLayer.background(255);

  cursorLayer = createGraphics(900, 700);

  brushX = width / 2;
  brushY = height / 2;
  cursorX = width / 2;
  cursorY = height / 2;
  randomAngle = random(TWO_PI);
}

function draw() {
  background(255);

  let invertedX = width - mouseX;
  let invertedY = height - mouseY;
  cursorX = lerp(cursorX, invertedX, 0.005);
  cursorY = lerp(cursorY, invertedY, 0.005);

  let d = dist(brushX, brushY, cursorX, cursorY);
  let moveX = 0;
  let moveY = 0;

  if (d < avoidanceRadius) {
    let angle = atan2(brushY - cursorY, brushX - cursorX);
    let superSpeed = brushSpeed * 10;
    moveX = cos(angle) * superSpeed;
    moveY = sin(angle) * superSpeed;
  } else {
    randomAngle += random(-PI / 16, PI / 16);
    moveX = cos(randomAngle) * brushSpeed;
    moveY = sin(randomAngle) * brushSpeed;
  }

  let centerX = (100 + 875) / 2.0;
  let centerY = (175 + 600) / 2.0;
  let toCenterX = centerX - brushX;
  let toCenterY = centerY - brushY;
  moveX += toCenterX * centerPullStrength / width;
  moveY += toCenterY * centerPullStrength / height;

  if (brushX < 100) moveX += edgeRepulsionStrength;
  if (brushX > 875) moveX -= edgeRepulsionStrength;
  if (brushY < 175) moveY += edgeRepulsionStrength;
  if (brushY > 600) moveY -= edgeRepulsionStrength;

  let prevBrushX = brushX;
  let prevBrushY = brushY;

  brushX += moveX;
  brushY += moveY;

  brushX = constrain(brushX, 100, 875);
  brushY = constrain(brushY, 175, 600);

  brushLayer.stroke(0);
  brushLayer.strokeWeight(4);
  brushLayer.line(prevBrushX, prevBrushY, brushX, brushY);
  image(brushLayer, -width/2, -height/2);

  image(menuImage, -width/2, -height/2, 900, 700);
  image(brushIcon, brushX - brushIconSize / 3 - width/2, brushY - brushIconSize - height/2, brushIconSize, brushIconSize);

  let fakeInside = (cursorX >= 100 && cursorX <= 875 && cursorY >= 175 && cursorY <= 600);
  let currentCursor = fakeInside ? cursorGrab : cursorIdle;

  cursorLayer.clear();

  if (fakeInside) {
    cursorLayer.image(currentCursor, cursorX - currentCursor.width / 2, cursorY - currentCursor.height / 2);
  } else {
    let scale = 0.35;
    let scaledW = currentCursor.width * scale;
    let scaledH = currentCursor.height * scale;
    cursorLayer.image(currentCursor, cursorX - scaledW / 2, cursorY - scaledH / 2, scaledW, scaledH);
  }

  image(cursorLayer, -width/2, -height/2);

  if (showWarning) {
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    textSize(22);
    text("Please first capture the brush before proceeding with further action", 0, 0);
    warningTimer--;
    if (warningTimer <= 0) showWarning = false;
  }
}

function mousePressed() {
  let fakeInside = (cursorX >= 100 && cursorX <= 875 && cursorY >= 175 && cursorY <= 600);
  if (!fakeInside) {
    showWarning = true;
    warningTimer = warningDuration;
  }
}
