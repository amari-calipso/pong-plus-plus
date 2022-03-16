new class FlyingObstacle : Obstacle {
    enum {
        LEFT, RIGHT, TOP, BOTTOM
    }

    new method __init__(pos, mode) {
        this.pos = pos;

        new dynamic tmp = randint(MIN_OBSTACLE_SIZE, MAX_OBSTACLE_SIZE);
        this.size     = Vector(tmp, tmp);
        this.mode     = mode;
        this.velocity = randint(MIN_FLYINGOBST_SPEED, MAX_FLYINGOBST_SPEED);
    }

    new method isAlive() {
        match this.mode {
            case FlyingObstacle.LEFT {
                return this.pos.x < RESOLUTION.x;
            }
            case FlyingObstacle.RIGHT {
                return this.pos.x > 0;
            }
            case FlyingObstacle.TOP {
                return this.pos.y < RESOLUTION.y;
            }
            case FlyingObstacle.BOTTOM {
                return this.pos.y > 0;
            }
        }
    }

    new method update() {
        new dynamic pt1, pt2;

        match this.mode {
            case FlyingObstacle.LEFT {
                this.pos.x += this.velocity;

                pt1 = this.pos.copy();
                pt1.y += this.size.y;

                pt2 = this.pos + this.size;
                pt2.y -= this.size.y // 2;

                graphics.polygon((this.pos, pt1, pt2), FG);
            }
            case FlyingObstacle.RIGHT {
                this.pos.x -= this.velocity;

                pt1 = this.pos.copy();
                pt2 = this.pos.copy();

                pt1.y += this.size.y // 2;
                pt2.x += this.size.x;

                graphics.polygon((pt1, pt2, this.pos + this.size), FG);
            }
            case FlyingObstacle.TOP {
                this.pos.y += this.velocity;

                pt1 = this.pos.copy();
                pt1.x += this.size.x;

                pt2 = this.pos + this.size;
                pt2.x -= this.size.x // 2;

                graphics.polygon((this.pos, pt1, pt2), FG);
            }
            case FlyingObstacle.BOTTOM {
                this.pos.y -= this.velocity;

                pt1 = this.pos.copy();
                pt2 = this.pos.copy();

                pt1.y += this.size.y;
                pt2.x += this.size.x // 2;

                graphics.polygon((pt1, pt2, this.pos + this.size), FG);
            }
        }

        if DEBUG_MODE {
            graphics.fastRectangle(this.pos, this.size, HITBOX_COLOR, DEBUG_LINES_WIDTH);

            new dynamic tmp;
            if this.mode in (FlyingObstacle.LEFT, FlyingObstacle.RIGHT) {
                tmp = this.pos.y + this.size.y // 2;
                graphics.line(Vector(0, tmp), Vector(RESOLUTION.x, tmp), INFO_COLOR, DEBUG_LINES_WIDTH);
            } else {
                tmp = this.pos.x + this.size.x // 2;
                graphics.line(Vector(tmp, 0), Vector(tmp, RESOLUTION.y), INFO_COLOR, DEBUG_LINES_WIDTH);
            }
        }
    }
}