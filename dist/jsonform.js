window.jsonform = {};

jsonform.AjaxField = (function() {
  function AjaxField() {
    console.log("here");
  }

  return AjaxField;

})();

jsonform.BooleanField = (function() {
  function BooleanField(config) {
    this.jel = $("<div></div>");
    this.el = this.jel[0];
    this.config = config;
    this.tmpl = JST["fields/boolean"];
  }

  BooleanField.prototype.render = function() {
    this.jel.html(this.tmpl(this.config));
    return this.jel.find(".chosen-select").chosen({
      disable_search_threshold: 5,
      width: "300px"
    }).change((function(_this) {
      return function() {
        return _this.jel.trigger('jf:change');
      };
    })(this));
  };

  BooleanField.prototype.getValue = function() {
    return this.jel.find(".chosen-select").val() === "true";
  };

  return BooleanField;

})();

jsonform.Form = (function() {
  function Form(txtArea, jsonConfig) {
    this.jel = $('<div class="jfForm"></div>');
    this.jtxt = $(txtArea);
    this.fields = [];
    this.jsonConfig = jsonConfig;
    this.parseJsonConfig(jsonConfig);
    _.each(this.fields, (function(_this) {
      return function(field) {
        _this.jel.append(field.el);
        field.render();
        return field.jel.on("jf:change", function() {
          var json;
          json = _this.generateJson(_this.jsonConfig);
          return console.log(json);
        });
      };
    })(this));
    this.jtxt.after(this.jel);
  }

  Form.prototype.generateJson = function(obj) {
    var newObj;
    if (_.isArray(obj)) {
      return _.map(obj, (function(_this) {
        return function(v) {
          return _this.generateJson(v);
        };
      })(this));
    } else {
      if (obj.jfField) {
        return obj.jfField.getValue();
      } else {
        newObj = {};
        _.each(obj, (function(_this) {
          return function(v, k) {
            return newObj[k] = _this.generateJson(v);
          };
        })(this));
        return newObj;
      }
    }
  };

  Form.prototype.parseJsonConfig = function(obj) {
    var field, klass;
    if (_.isArray(obj)) {
      return _.each(obj, (function(_this) {
        return function(v) {
          return _this.parseJsonConfig(v);
        };
      })(this));
    } else {
      if (!!obj.jfType) {
        klass = jsonform[obj.jfType];
        if (klass) {
          field = new jsonform[obj.jfType](obj);
          obj.jfField = field;
          return this.fields.push(field);
        } else {
          return console.error("jsonform field doesnt exist: " + obj.jfType);
        }
      } else {
        return _.each(obj, (function(_this) {
          return function(v, k) {
            if (_.isObject(v)) {
              return _this.parseJsonConfig(v);
            }
          };
        })(this));
      }
    }
  };

  return Form;

})();

this.JST = {"fields/ajax": function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += 'This is ajax';

}
return __p
},
"fields/boolean": function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {

 if(jfTitle) { ;
__p += '<span class="jfTitle">' +
((__t = ( jfTitle )) == null ? '' : __t) +
'</span>';
 } ;
__p += '\n\n<select class="chosen-select">\n  <option value="true">true</option>\n  <option value="false">false</option>\n</select>';

}
return __p
}};