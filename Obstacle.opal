new class Obstacle {
    new method __init__(pos) {
        new dynamic tmp = randint(MIN_OBSTACLE_SIZE, MAX_OBSTACLE_SIZE);

        this.size     = Vector(tmp, tmp);
        this.pos      = pos - this.size // 2;
        this.lifeSpan = randint(MIN_OBSTACLE_LIFE, MAX_OBSTACLE_LIFE);

        this.step  = OBSTACLE_DELTA_ALPHA;
        this.alpha = OBSTACLE_START_ALPHA;
    }

    new method isAlive() {
        return this.alpha > 0;
    }

    new method update() {
        if this.lifeSpan == 0 {
            this.step = -OBSTACLE_DELTA_ALPHA;
        }

        this.alpha = Utils.limitToRange(this.alpha + this.step, 0, 255);
        graphics.rectangle(this.pos, this.size, FG, alpha = this.alpha);
        this.lifeSpan--;

        if DEBUG_MODE {
            graphics.fastRectangle(this.pos, this.size, HITBOX_COLOR, DEBUG_LINES_WIDTH);
        }
    }

    new method collides(player) {
        new dynamic yr = range(this.pos.y, this.pos.y + this.size.y),
                    xr = range(this.pos.x, this.pos.x + this.size.x);

        new int     playerPosY = player.pos.y;
        new dynamic playerPosX = player.pos.x;

        if (playerPosX in xr or playerPosX + PLAYER_SIZE in xr) and (playerPosY in yr or playerPosY + PLAYER_SIZE in yr) {
            return True;
        }

        return False;
    }
}