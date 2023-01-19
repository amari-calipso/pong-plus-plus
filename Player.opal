new class Player {
    new method __init__() {
        this.__reset();
        this.explosion = Explosion(this.pos);

        this.resetRays();

        this.gradient = graphics.loadImage(
            os.path.join(HOME_DIR, "gradient.png"),
            RESOLUTION * 2
        );
    }

    new method resetRays() {
        this.rays = [];
        for i in range(RAYS_QTY) {
            this.rays.append(Ray(this.pos + PLAYER_SIZE_VEC // 2, math.radians(i * (360 / RAYS_QTY))));
        }
    }

    property pos {
        set {
            this.__pos = value;

            for i in range(len(this.rays)) {
                this.rays[i].pos = value + PLAYER_SIZE_VEC // 2;
            }
        }
        get {
            return this.__pos;
        }
    }

    new method __reset() {
        this.__hoverAngle = 0;

        this.count    = 0;
        this.playing  = False;
        this.dead     = False;
        this.__pos    = CENTER.copy() - PLAYER_SIZE_VEC // 2;
        this.velocity = Vector();

        this.__rainbow    = False;
        this.__rainbowCnt = 0;

        this.sprinting = False;
    }

    new method sprintOn() {
        this.sprinting = True;
        this.velocity.y = 0;
    }

    new method sprintOff() {
        this.sprinting = False;
    }

    new method rainbowOn() {
        this.__rainbow    = True;
        this.__rainbowCnt = 0;
    }

    new method rainbowOff() {
        this.__rainbow = False;
    }

    new method start() {
        this.playing  = True;
        this.velocity = PLAYER_VELOCITY if randint(0, 1) == 0 else -PLAYER_VELOCITY;
    }

    new method invert() {
        this.count++;
        this.velocity.x = -this.velocity.x;
    }

    new method jump() {
        if not this.playing {
            this.start();
        }

        if not this.sprinting {
            this.velocity.y = -JUMP_VELOCITY;
        }
    }

    new method isDead() {
        if this.dead {
            this.explosion.explode(this.pos);
            this.__reset();

            return True;
        }

        if this.pos.x <= 0 {
            this.explosion.explode(Vector(0, this.pos.y));
        } elif this.pos.x + PLAYER_SIZE >= RESOLUTION.x {
            this.explosion.explode(Vector(RESOLUTION.x - 1, this.pos.y));
        } elif this.pos.y <= 0 {
            this.explosion.explode(Vector(this.pos.x, 0));
        } elif this.pos.y + PLAYER_SIZE >= RESOLUTION.y {
            this.explosion.explode(Vector(this.pos.x, RESOLUTION.y - 1));
        } else {
            return False;
        }

        this.__reset();
        return True;
    }

    new method __getDir() {
        return 1 if this.velocity.x > 0 else -1;
    }

    new method look(walls) {
        new dynamic points = [],
                    pos    = this.pos + PLAYER_SIZE_VEC // 2;

        for i = 0; i < len(this.rays); i++ {
            new dynamic closest = None;
            new float    record = sys.maxsize;

            for j = 0; j < len(walls); j++ {
                new dynamic pt = this.rays[i].cast(walls[j]);
                if pt is not None {
                    new float d = pos.distance(pt);

                    if d < record {
                        record  = d;
                        closest = pt;
                    }
                }
            }

            if closest is not None {
                if DEBUG_MODE {
                    graphics.line(pos, closest, RAY_COLOR, DEBUG_LINES_WIDTH);
                }

                points.append(closest);
            }
        }

        new dynamic surf = Surface(RESOLUTION.toList(2), SRCALPHA), color;

        if this.__rainbow or this.sprinting {
            color = hsvToRgb(this.__rainbowCnt);
        } else {
            color = FG;
        }

        for i = 0; i < len(points) - 1; i++ {
            graphics.polygon(
                (pos, points[i], points[i + 1]),
                color + (50, ),
                surf = surf
            );
        }

        graphics.polygon(
            (pos, points[len(points) - 1], points[0]),
            color + (50, ),
            surf = surf
        );
        
        surf.blit(
            this.gradient, (pos.x - RESOLUTION.x, 
            pos.y - RESOLUTION.y),
            special_flags = BLEND_RGBA_MULT
        );
    
        graphics.blitSurf(surf, Vector());
    }

    new method update() {
        if this.explosion.isAlive() {
            this.explosion.update();
            this.explosion.show();
        } else {
            if this.playing {
                if this.sprinting {
                    this.pos.x += SPRINT_VELOCITY * this.__getDir();
                } else {
                    this.velocity += GRAVITY;
                    this.pos += this.velocity;
                }

                if this.__rainbow or this.sprinting {
                    graphics.fastRectangle(this.pos, PLAYER_SIZE_VEC, hsvToRgb(this.__rainbowCnt));

                    this.__rainbowCnt += RAINBOW_DELTA;
                    if this.__rainbowCnt > 1 {
                        this.__rainbowCnt = 0;
                    }
                } else {
                    graphics.fastRectangle(this.pos, PLAYER_SIZE_VEC, FG);
                }
            } else {
                new dynamic tmpPos = this.pos.copy();
                tmpPos.y += round(math.sin(this.__hoverAngle) * HOVER_AMPLITUDE);
                graphics.fastRectangle(tmpPos, PLAYER_SIZE_VEC, FG);
                this.__hoverAngle += HOVER_ANGLE_INCREMENT;
            }

            if DEBUG_MODE {
                new dynamic center = this.pos + PLAYER_SIZE_VEC // 2,
                            vel    = this.velocity.copy();
                graphics.fastRectangle(this.pos, PLAYER_SIZE_VEC, HITBOX_COLOR, DEBUG_LINES_WIDTH);
                graphics.line(center, center + vel.magnitude(DEBUG_VELOCITY_LEN), INFO_COLOR, DEBUG_LINES_WIDTH);

                graphics.fastRectangle(this.pos - PLAYER_SAFE_ZONE, PLAYER_SIZE_VEC + PLAYER_SAFE_ZONE * 2, SAFE_ZONE_COLOR, DEBUG_LINES_WIDTH);
            }
        }
    }
}