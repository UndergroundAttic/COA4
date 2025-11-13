class Block extends Object {
	float speedX;
	int col;      // 현재 이동 블록 색

	Block(PVector pos, float w, float h, float speedX) {
		super(pos, w, h);
		this.speedX = speedX;
		this.col = color(90, 200, 255);
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