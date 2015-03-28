# JSON form

This is a javascript library that can auto-generate a form to help a user generate a JSON document.

You use JSON form by providing a textarea DOM element (empty or filled with existing JSON data), and a JSON object that describes the JSON you want to manipulate via the form.

```js
var configObject = {
  ...      
};
var jf = new jsonform.Form($("#myTextField")[0], configObject);
```

Also parse existing data