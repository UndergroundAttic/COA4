class Block extends Object {
	float speedX;

	Block(PVector pos, float w, float h, float speedX, int col) {
		super(pos, w, h);
		this.speedX = speedX;
		this.col = col;
	}

	void updateHorizontalBounce(float leftBound, float rightBound) {
		position.x += speedX;
		if (position.x < leftBound) {
			position.x = leftBound;
			speedX *= -1;
		} else if (position.x > rightBound) {
			position.x = rightBound;
			speedX *= -1;
		}
	}

	void display() {
		fill(col);
		rect(position.x, position.y, width, height);
	}
}