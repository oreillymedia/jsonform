window.jsonform = {};

window.jsonform.helpers = {
  panic: function(msg) {
    console.error(msg);
    return alert(msg);
  },
  isJsonString: function(str) {
    var e;
    try {
      JSON.parse(str);
    } catch (_error) {
      e = _error;
      return false;
    }
    return true;
  },
  changed: function() {
    return jQuery.event.trigger('jf:change');
  },
  newField: function(jfObj) {
    var klass;
    klass = jsonform[jfObj.jfType];
    if (klass) {
      return new jsonform[jfObj.jfType](jfObj);
    } else {
      return console.error("jsonform field doesnt exist: " + jfObj.jfType);
    }
  }
};

jsonform.AjaxField = (function() {
  AjaxField.findExtraValues = function(config, vals, success) {
    var query;
    vals = _.compact(vals);
    if (_.isEmpty(vals)) {
      return;
    }
    query = {};
    query[config.jfReloadParam] = vals;
    return $.ajax({
      url: config.jfUrl,
      data: query,
      type: 'GET',
      success: (function(_this) {
        return function(data) {
          return success(config.jfParse(data, vals));
        };
      })(this),
      error: function(data) {
        return console.log("error baby");
      }
    });
  };

  function AjaxField(config) {
    this.config = config;
    this.tmpl = JST["fields/ajax"];
    this.jel = $('<div class="jfField"></div>');
    this.el = this.jel[0];
  }

  AjaxField.prototype.render = function() {
    var timeout;
    timeout = void 0;
    this.jel.html(this.tmpl(this.config));
    this.chosen = this.jel.find(".chosen-select").chosen({
      width: "300px",
      allow_single_deselect: true,
      no_results_text: 'Searching for'
    });
    this.jel.find(".chosen-search input").on('input', (function(_this) {
      return function(e) {
        clearTimeout(timeout);
        return timeout = setTimeout(function() {
          return _this.loadAjax(e);
        }, 800);
      };
    })(this));
    return this.chosen.change(jsonform.helpers.changed);
  };

  AjaxField.prototype.getValue = function() {
    return this.jel.find(".chosen-select").val();
  };

  AjaxField.prototype.clearValues = function() {
    this.jel.find("select option").remove();
    this.jel.find("select").append("<option value=\"\"></option>");
    return this.jel.find(".chosen-select").trigger("chosen:updated");
  };

  AjaxField.prototype.setValue = function(val) {
    if (!_.isObject(val)) {
      return this.constructor.findExtraValues(this.config, [val], (function(_this) {
        return function(newVal) {
          return _this.setValue(newVal[0]);
        };
      })(this));
    } else {
      this.jel.find(".chosen-select").html('<option value></option><option value="' + val[0] + '">' + val[1] + '</option>');
      this.jel.find(".chosen-select").val(val[0]);
      this.jel.find(".chosen-select").trigger("chosen:updated");
      return jsonform.helpers.changed();
    }
  };

  AjaxField.prototype.loadAjax = function(e) {
    var chosen, query, searchVal;
    chosen = this.jel.find(".chosen-container");
    query = {};
    searchVal = chosen.find(".chosen-search input").val();
    query[this.config.jfSearchParam] = searchVal;
    this.clearValues();
    return $.ajax({
      url: this.config.jfUrl,
      data: query,
      type: 'GET',
      success: (function(_this) {
        return function(data) {
          var results, select;
          results = _this.config.jfParse(data);
          if (results.length === 0) {
            return chosen.find(".chosen-results").html("<li class=\"no-results\">No results matched \"<span>" + searchVal + "</span>\"</li>");
          } else {
            select = _this.jel.find(".chosen-select");
            _.each(results, function(result) {
              return select.append('<option value="' + result[0] + '">' + result[1] + '</option>');
            });
            select.trigger("chosen:updated");
            return chosen.find(".chosen-search input").val(searchVal);
          }
        };
      })(this),
      error: function(data) {
        return console.log("error baby");
      }
    });
  };

  return AjaxField;

})();

jsonform.BooleanField = (function() {
  function BooleanField(config) {
    this.config = config;
    this.tmpl = JST["fields/boolean"];
    this.jel = $('<div class="jfField"></div>');
    this.el = this.jel[0];
  }

  BooleanField.prototype.render = function() {
    this.jel.html(this.tmpl(this.config));
    return this.jel.find(".chosen-select").chosen({
      disable_search_threshold: 5,
      width: "300px"
    }).change(jsonform.helpers.changed);
  };

  BooleanField.prototype.getValue = function() {
    return this.jel.find(".chosen-select").val() === "true";
  };

  BooleanField.prototype.setValue = function(val) {
    this.jel.find(".chosen-select").val(val + "");
    return this.jel.find(".chosen-select").trigger("chosen:updated");
  };

  return BooleanField;

})();

jsonform.FieldCollection = (function() {
  function FieldCollection(config) {
    this.config = config;
    this.tmpl = JST["fields/fieldcollection"];
    this.deltmpl = JST["fields/fieldcollection-del"];
    this.sorttmpl = JST["fields/fieldcollection-sort"];
    this.jel = $("<div></div>");
    this.el = this.jel[0];
    this.fields = [];
  }

  FieldCollection.prototype.render = function() {
    this.jel.html(this.tmpl(this.config));
    this.jel.find(".jfAdd").click((function(_this) {
      return function(e) {
        if ($(_this).is("[disabled]")) {
          return;
        }
        e.preventDefault();
        return _this.addOne();
      };
    })(this));
    if ($().sortable) {
      return this.jel.find(".jfCollection").sortable({
        placeholder: '<span class="placeholder">&nbsp;</span>',
        itemSelector: '.jfField',
        handle: 'i.jfSort',
        onDrop: (function(_this) {
          return function(item, container, _super) {
            _super(item, container);
            _this.fields = _.sortBy(_this.fields, function(field) {
              return field.jel.index();
            });
            return jsonform.helpers.changed();
          };
        })(this)
      });
    }
  };

  FieldCollection.prototype.getValues = function() {
    var results;
    results = _.map(this.fields, function(field) {
      return field.getValue();
    });
    return _.compact(results);
  };

  FieldCollection.prototype.addOne = function(defaultValue) {
    var del, field, fieldConfig;
    fieldConfig = _.extend({}, this.config);
    delete fieldConfig.jfTitle;
    delete fieldConfig.jfHelper;
    field = jsonform.helpers.newField(fieldConfig);
    this.fields.push(field);
    this.jel.find(".jfCollection").append(field.el);
    field.render();
    if (!_.isUndefined(defaultValue)) {
      field.setValue(defaultValue);
    }
    if ($().sortable) {
      field.jel.prepend(this.sorttmpl());
    }
    del = $(this.deltmpl());
    field.jel.append(del);
    del.click((function(_this) {
      return function(e) {
        e.preventDefault();
        del.remove();
        field.jel.remove();
        _this.fields = _.without(_this.fields, field);
        _this.checkAddState();
        return jsonform.helpers.changed();
      };
    })(this));
    this.checkAddState();
    if ($().sortable) {
      this.jel.find(".jfCollection").sortable("refresh");
    }
    return jsonform.helpers.changed();
  };

  FieldCollection.prototype.fieldsFromValues = function(vals) {
    if (jsonform[this.config.jfType].findExtraValues) {
      return jsonform[this.config.jfType].findExtraValues(this.config, vals, (function(_this) {
        return function(vals) {
          return _.each(vals, function(val) {
            return _this.addOne(val);
          });
        };
      })(this));
    } else {
      return _.each(vals, (function(_this) {
        return function(val) {
          return _this.addOne(val);
        };
      })(this));
    }
  };

  FieldCollection.prototype.checkAddState = function() {
    if (this.config.jfMax) {
      if (this.fields.length >= this.config.jfMax) {
        return this.jel.find(".jfAdd").attr("disabled", "disabled");
      } else {
        return this.jel.find(".jfAdd").removeAttr("disabled");
      }
    }
  };

  return FieldCollection;

})();

jsonform.SelectField = (function() {
  function SelectField(config) {
    this.config = config;
    this.tmpl = JST["fields/select"];
    this.jel = $('<div class="jfField"></div>');
    this.el = this.jel[0];
  }

  SelectField.prototype.render = function() {
    this.jel.html(this.tmpl(this.config));
    return this.jel.find(".chosen-select").chosen({
      disable_search_threshold: 5,
      width: "300px"
    }).change((function(_this) {
      return function() {
        _this.jel.trigger("jf:changed");
        return jsonform.helpers.changed();
      };
    })(this));
  };

  SelectField.prototype.getValue = function() {
    return this.jel.find(".chosen-select").val();
  };

  SelectField.prototype.setValue = function(val) {
    this.jel.find(".chosen-select").val(val + "");
    return this.jel.find(".chosen-select").trigger("chosen:updated");
  };

  return SelectField;

})();

jsonform.SelectAjaxField = (function() {
  function SelectAjaxField(config) {
    this.config = config;
    this.jel = $('<div class="jfField"></div>');
    this.el = this.jel[0];
    this.selectField = new jsonform.SelectField({
      jfValues: _.map(this.config.jfValues, function(val) {
        return val.jfValue;
      })
    });
    this.ajaxField = new jsonform.AjaxField(this.config.jfValues[0]);
  }

  SelectAjaxField.prototype.render = function() {
    this.jel.html("");
    this.jel.append(this.selectField.el);
    this.jel.append(this.ajaxField.el);
    this.selectField.render();
    this.ajaxField.render();
    return this.selectField.jel.on("jf:changed", (function(_this) {
      return function() {
        return _this.selectSwitched();
      };
    })(this));
  };

  SelectAjaxField.prototype.getValue = function() {
    var val;
    val = {};
    val[this.config.jfSelectKey] = this.selectField.getValue();
    val[this.config.jfAjaxKey] = this.ajaxField.getValue();
    return val;
  };

  SelectAjaxField.prototype.setValue = function(val) {
    var ajaxConfig;
    this.selectField.setValue(val[this.config.jfSelectKey]);
    ajaxConfig = this.getConfigBySelectKey(this.selectField.getValue());
    return jsonform.AjaxField.findExtraValues(ajaxConfig, [val[this.config.jfAjaxKey]], (function(_this) {
      return function(data) {
        _this.ajaxField.config = ajaxConfig;
        return _this.ajaxField.setValue(data[0]);
      };
    })(this));
  };

  SelectAjaxField.prototype.selectSwitched = function() {
    var ajaxConfig;
    ajaxConfig = this.getConfigBySelectKey(this.selectField.getValue());
    this.ajaxField.config = ajaxConfig;
    return this.ajaxField.setValue(["", ""]);
  };

  SelectAjaxField.prototype.getConfigBySelectKey = function(key) {
    return _.find(this.config.jfValues, function(conf) {
      return conf.jfValue[0] === key;
    });
  };

  return SelectAjaxField;

})();

jsonform.StringField = (function() {
  function StringField(config) {
    this.config = config;
    this.tmpl = JST["fields/string"];
    this.jel = $('<div class="jfField"></div>');
    this.el = this.jel[0];
  }

  StringField.prototype.render = function() {
    this.jel.html(this.tmpl(this.config));
    return this.jel.find("input").change(jsonform.helpers.changed);
  };

  StringField.prototype.getValue = function() {
    return this.jel.find("input").val();
  };

  StringField.prototype.setValue = function(val) {
    return this.jel.find("input").val(val);
  };

  return StringField;

})();

jsonform.Form = (function() {
  function Form(txtArea, jsonConfig) {
    var txtval;
    this.jel = $('<div class="jfForm"></div>');
    this.jtxt = $(txtArea);
    this.jtxt.hide();
    this.fields = [];
    this.jsonConfig = jsonConfig;
    this.parseJsonConfig(this.jsonConfig);
    _.each(this.fields, (function(_this) {
      return function(field) {
        _this.jel.append(field.el);
        return field.render();
      };
    })(this));
    $(document).bind('jf:change', (function(_this) {
      return function() {
        var json;
        json = _this.generateJson(_this.jsonConfig);
        return _this.jtxt.val(JSON.stringify(json, null, 2));
      };
    })(this));
    this.jtxt.after(this.jel);
    txtval = this.jtxt.val();
    if (!!txtval) {
      if (jsonform.helpers.isJsonString(txtval)) {
        this.fillFields(JSON.parse(txtval), this.jsonConfig);
      } else {
        jsonform.helpers.panic("Textarea has invalid JSON. jsonform will not work");
      }
    }
  }

  Form.prototype.generateJson = function(obj) {
    var newObj, val, vals;
    if (_.isArray(obj)) {
      if (obj.length === 1 && obj[0].jfCollection) {
        vals = obj[0].jfCollection.getValues();
        if (obj[0].jfCollection.config.jfValueType === "int") {
          vals = _.map(vals, function(val) {
            return parseInt(val);
          });
        }
        return vals;
      } else {
        return _.map(obj, (function(_this) {
          return function(v) {
            return _this.generateJson(v);
          };
        })(this));
      }
    } else {
      if (obj.jfField) {
        val = obj.jfField.getValue();
        if (obj.jfField.config.jfValueType === "int") {
          val = parseInt(val);
        }
        return val;
      } else {
        if (_.isObject(obj)) {
          newObj = {};
          _.each(obj, (function(_this) {
            return function(v, k) {
              return newObj[k] = _this.generateJson(v);
            };
          })(this));
          return newObj;
        } else {
          return obj;
        }
      }
    }
  };

  Form.prototype.parseJsonConfig = function(obj) {
    if (_.isArray(obj)) {
      if (obj.length === 1 && obj[0].jfType) {
        obj[0].jfCollection = new jsonform.FieldCollection(obj[0]);
        return this.fields.push(obj[0].jfCollection);
      } else {
        return _.each(obj, (function(_this) {
          return function(v) {
            return _this.parseJsonConfig(v);
          };
        })(this));
      }
    } else {
      if (obj.jfType) {
        obj.jfField = jsonform.helpers.newField(obj);
        return this.fields.push(obj.jfField);
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

  Form.prototype.fillFields = function(obj, jsonConfig) {
    if (obj === void 0 || jsonConfig === void 0) {
      jsonform.helpers.panic("Existing JSON doesnt match JSON config.");
    }
    if (_.isArray(obj)) {
      if (jsonConfig.length === 1 && jsonConfig[0].jfCollection) {
        return jsonConfig[0].jfCollection.fieldsFromValues(obj);
      } else {
        return _.each(obj, (function(_this) {
          return function(v, i) {
            return _this.fillFields(obj[i], jsonConfig[i]);
          };
        })(this));
      }
    } else {
      if (jsonConfig.jfField) {
        return jsonConfig.jfField.setValue(obj);
      } else {
        if (_.isObject(obj)) {
          return _.each(obj, (function(_this) {
            return function(v, k) {
              if (jsonConfig[k]) {
                return _this.fillFields(v, jsonConfig[k]);
              } else {
                console.log("jsonConfig object not present:");
                console.log("key: ", k);
                return console.log("value: ", v);
              }
            };
          })(this));
        }
      }
    }
  };

  return Form;

})();

this.JST = {"fields/ajax": function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {

 if(typeof(jfTitle)!== 'undefined') { ;
__p += '<span class="jfTitle">' +
((__t = ( jfTitle )) == null ? '' : __t) +
'</span>';
 } ;
__p += '\n';
 if(typeof(jfHelper)!== 'undefined') { ;
__p += '<span class="jfHelper">' +
((__t = ( jfHelper )) == null ? '' : __t) +
'</span>';
 } ;
__p += '\n\n<select class="chosen-select">\n  <option value=""></option>\n</select>';

}
return __p
},
"fields/boolean": function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {

 if(typeof(jfTitle)!== 'undefined') { ;
__p += '<span class="jfTitle">' +
((__t = ( jfTitle )) == null ? '' : __t) +
'</span>';
 } ;
__p += '\n';
 if(typeof(jfHelper)!== 'undefined') { ;
__p += '<span class="jfHelper">' +
((__t = ( jfHelper )) == null ? '' : __t) +
'</span>';
 } ;
__p += '\n\n<select class="chosen-select">\n  <option value="true">true</option>\n  <option value="false">false</option>\n</select>';

}
return __p
},
"fields/fieldcollection-del": function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<a href="#" class="jfDel jfBtn">-</a>';

}
return __p
},
"fields/fieldcollection-sort": function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<i class="jfSort">&#8597;</i>';

}
return __p
},
"fields/fieldcollection": function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {

 if(typeof(jfTitle)!== 'undefined') { ;
__p += '<span class="jfTitle">' +
((__t = ( jfTitle )) == null ? '' : __t) +
'</span>';
 } ;
__p += '\n';
 if(typeof(jfHelper)!== 'undefined') { ;
__p += '<span class="jfHelper">' +
((__t = ( jfHelper )) == null ? '' : __t) +
'</span>';
 } ;
__p += '\n\n<a href="#" class="jfAdd jfBtn">+</a>\n\n<div class="jfCollection"></div>';

}
return __p
},
"fields/select": function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {

 if(typeof(jfTitle)!== 'undefined') { ;
__p += '<span class="jfTitle">' +
((__t = ( jfTitle )) == null ? '' : __t) +
'</span>';
 } ;
__p += '\n';
 if(typeof(jfHelper)!== 'undefined') { ;
__p += '<span class="jfHelper">' +
((__t = ( jfHelper )) == null ? '' : __t) +
'</span>';
 } ;
__p += '\n\n<select class="chosen-select">\n  ';
 _.each(jfValues, function(val) { ;
__p += '\n    <option value="' +
((__t = ( val[0] )) == null ? '' : __t) +
'">' +
((__t = ( val[1] )) == null ? '' : __t) +
'</option>\n  ';
 }); ;
__p += '\n</select>';

}
return __p
},
"fields/selectajax": function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {

 if(typeof(jfTitle)!== 'undefined') { ;
__p += '<span class="jfTitle">' +
((__t = ( jfTitle )) == null ? '' : __t) +
'</span>';
 } ;
__p += '\n';
 if(typeof(jfHelper)!== 'undefined') { ;
__p += '<span class="jfHelper">' +
((__t = ( jfHelper )) == null ? '' : __t) +
'</span>';
 } ;
__p += '\n\n<select class="chosen-select">\n  ';
 _.each(jfValues, function(val) { ;
__p += '\n    <option value="' +
((__t = ( val.jfValue[0] )) == null ? '' : __t) +
'">' +
((__t = ( val.jfValue[1] )) == null ? '' : __t) +
'</option>\n  ';
 }); ;
__p += '\n</select>';

}
return __p
},
"fields/string": function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {

 if(typeof(jfTitle)!== 'undefined') { ;
__p += '<span class="jfTitle">' +
((__t = ( jfTitle )) == null ? '' : __t) +
'</span>';
 } ;
__p += '\n';
 if(typeof(jfHelper)!== 'undefined') { ;
__p += '<span class="jfHelper">' +
((__t = ( jfHelper )) == null ? '' : __t) +
'</span>';
 } ;
__p += '\n\n<input type="text" />';

}
return __p
}};