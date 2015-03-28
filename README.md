# JSON form

This is a javascript library that can auto-generate a form to help a user generate a JSON document.

You use JSON form by providing a textarea DOM element (empty or filled with existing JSON data), and a JSON object that describes the JSON you want to manipulate via the form.

```js
var config = {
  ...      
}
var jf = new jsonform.Form($("#myTextField")[0], config);
```

## The config object

The config object defines the outline of the JSON object that the library should generate. You can use any type of object: The only requirement is that whereever you need dynamic data input, you create an object with at least the property `jsType` set to the type of field to show the user.

The following json config shows a single textfield to the user:

```js
var config = {
  "name" : {
    "jfType" : "StringField"
  }    
}
```

The user will then be presented by a single textfield, and every edit will result in a JSON document in the original textarea that looks like this:

```html
<textarea>
{
  "name" : "whatever the user typed"
}
</textarea>
```

Although that's a very simple use-case, the library supports a number of more advanced fields. Look in the field parameters explanation below.

But what if you want the user to add more than a single name? Easy. Wrap your `jfType` object in an array, and the UI will show buttons to add/remove multiple fields. For example, this is a more complex example where a user can add up to 7 names:

```js
var config = {
  "names" : [
    {
      "jfType" : "StringField",
      "jfMax" : 7
    }
  ]    
}
```

Corresponding output:

```html
<textarea>
{
  "names" : [
    "whatever the user typed",
    "whatever the user typed"
    "whatever the user typed"
    "whatever the user typed"
    "whatever the user typed"
  ]
}
</textarea>
```

If the textarea has existing JSON data, and that data matches the schema of the JSON config, the existing JSON values will be pre-filled into the form.

Look in `test/index.html` for a more complicated JSON config structure.

## Field parameters

There's a number of fields in this library, each of them with specific parameters. First, here's a number of params that apply to all fields:

```js
{
  "jfType" : "XXXXField", // name of field to use
  "jfTitle" : "My title", // label to show before the input field(s)
  "jfHelper" : "Do this, do that", // smaller help text to show before the input field(s)
}
```

### BooleanField

No specific options. Will show a select box with `true` or `false`.

```js
{
  "jfType" : "BooleanField"
}
```

### StringField

No specific options. Will show an input text field.

```js
{
  "jfType" : "StringField"
}
```

### AjaxField

A more complex field. Will show a dropdown with search box, do a GET request against an external API to get results, and populate the results in the select box.

```js
{
  "jfType" : "AjaxField",
  "jfUrl" : "http://my.api", // URL for API endpoint
  "jfSearchParam" : "search", // query param to use for search query (http://my.api?search=QUERY)
  "jfReloadParam" : "uuid[]", // used to populate existing data. The field will make a single request with all values set to this array param, and use parse function to populate the fields. Look in test/index.html
  "jfParse" : function(data) { }) // Parse function that is passed the API response, and should return an array of [value, label] for the select.
}
```



