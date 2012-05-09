///////////////////////////////////////////////////////////////////////
//  RoundedRect
///////////////////////////////////////////////////////////////////////
/**
 * RoundedRect constructor
 * @constructor
 * @augments Kinetic.Shape
 * @param {Object} config
 */
Kinetic.RoundedRect = function(config) {
    // default attrs
    if(this.attrs === undefined) {
        this.attrs = {};
    }
    this.attrs.width = 0;
    this.attrs.height = 0;
    this.attrs.radius = 0;

    this.shapeType = "RoundedRect";

    config.drawFunc = function() {
        var context = this.getContext();
        context.beginPath();
        this.applyLineJoin();

        if (this.attrs.radius > 0) {
          var width = this.attrs.width,
              height = this.attrs.height,
              radius = this.attrs.radius,
              hw = Math.floor(width / 2),
              hh = Math.floor(height / 2);

          if (radius > hw) radius = hw;
          if (radius > hh) radius = hh;

          context.moveTo(0, radius);
          context.arcTo(0, 0, radius, 0, radius);
          context.lineTo(width - radius, 0);
          context.arcTo(width, 0, width, radius, radius);
          context.lineTo(width, height - radius);
          context.arcTo(width, height, width - radius, height, radius);
          context.lineTo(radius, height);
          context.arcTo(0, height, 0, height - radius, radius);
        } else {
          context.rect(0, 0, this.attrs.width, this.attrs.height);
        }

        context.closePath();
        this.fillStroke();
    };
    // call super constructor
    Kinetic.Shape.apply(this, [config]);
};
/*
 * RoundedRect methods
 */
Kinetic.RoundedRect.prototype = {
    /**
     * set width
     * @param {Number} width
     */
    setWidth: function(width) {
        this.attrs.width = width;
    },
    /**
     * get width
     */
    getWidth: function() {
        return this.attrs.width;
    },
    /**
     * set height
     * @param {Number} height
     */
    setHeight: function(height) {
        this.attrs.height = height;
    },
    /**
     * get height
     */
    getHeight: function() {
        return this.attrs.height;
    },
    /**
     * set radius
     * @param {Number} radius
     */
    setRadius: function(radius) {
        this.attrs.radius = radius;
    },
    /**
     * get radius
     */
    getRadius: function() {
        return this.attrs.radius;
    },
    /**
     * set width, height, radius
     * @param {Number} width
     * @param {Number} height
     * @param {Number} radius
     */
    setSize: function(width, height, radius) {
        this.attrs.width = width;
        this.attrs.height = height;
        if (typeof radius != "undefined")
          this.attrs.radius = radius;
    },
    /**
     * return rounded rect size
     */
    getSize: function() {
        return {
            width: this.attrs.width,
            height: this.attrs.height,
            radius: this.attrs.radius
        };
    }
};

//extend Shape
Kinetic.GlobalObject.extend(Kinetic.RoundedRect, Kinetic.Shape);

///////////////////////////////////////////////////////////////////////
//Line
///////////////////////////////////////////////////////////////////////
/**
* Line constructor
* @constructor
* @augments Kinetic.Shape
* @param {Object} config
*/
Kinetic.Line = function(config) {
  // default attrs
  if(this.attrs === undefined) {
      this.attrs = {};
  }

  delete config.fill;

  this.attrs.offsetX = 0;
  this.attrs.offsetY = 0;
  
  this.shapeType = "Line";
  
  config.drawFunc = function() {
      var context = this.getContext();
      context.beginPath();
      context.moveTo(0, 0);

      if (typeof this.attrs.toX != "undefined" && typeof this.attrs.toY != "undefined") {
        context.lineTo(
            this.attrs.toX - this.attrs.x,
            this.attrs.toY - this.attrs.y 
        );
      } else {
        context.lineTo(this.attrs.offsetX, this.attrs.offsetY);
      }

      context.closePath();
      this.fillStroke();
  };

  // call super constructor
  Kinetic.Shape.apply(this, [config]);
};
/*
* RoundedRect methods
*/
Kinetic.Line.prototype = {
    /**
     * set destination
     * @param {Number} x
     * @param {Number} y
     */
    to: function(x, y) {
      this.attrs.toX = x;
      this.attrs.toY = y;
    },
    /**
     * set offset
     * @param {Number} x
     * @param {Number} y
     */
    setOffset: function(x, y) {
      delete this.attrs.toX;
      delete this.attrs.toY;
      this.attrs.offsetX = x;
      this.attrs.offsetY = y;
    }
};

//extend Shape
Kinetic.GlobalObject.extend(Kinetic.Line, Kinetic.Shape);
