## Button
Creates a **Button** in the embed frame for user input.

### Properties
---
* OnHover `function`: Returns/sets the function for whenever the **Button** is hovered over.
* OnClick `function`: Returns/sets the function for whenever the **Button** is clicked.
* Text `string`: Returns/sets the text for the button.
* Color `color3`: Returns/sets the color button.
* TextColor `color3`: Returns/sets the text color.
* Font `Enum.Font`: Returns/sets the text font.
* TextSize `number`: Returns/sets the text size.
 ```XML
<button color="Color3.fromRGB(255, 0, 0)">Button Example</button>
```

## TextBox
Creates a **TextBox** in the embed frame for user input.

### Properties
---
* OnHover `Function`: Returns/sets the function for whenever the **TextBox** is hovered over.
* OnEnter`Function`: Returns/sets the function for whenever enter is pressed.
* Text `String`: Returns/sets the text for the button.
* Color `Color3`: Returns/sets the color button.
* TextColor `Color3`: Returns/sets the text color.
* Font `Enum.Font`: Returns/sets the text font.
* TextSize `Number`: Returns/sets the text size.
 ```XML
<textbox color="Color3.fromRGB(255, 0, 0)">TextBox Example</textbox>
```

## TextLabel
Creates a **TextLabel** in the embed frame.

### Properties
---
* OnHover `Function`: Returns/sets the function for whenever the **TextLabel** is hovered over.
* Text `String`: Returns/sets the text for the button.
* Color `Color3`: Returns/sets the color button.
* TextColor `Color3`: Returns/sets the text color.
* Font `Enum.Font`: Returns/sets the text font.
* TextSize `Mumber`: Returns/sets the text size.
 ```XML
<textlabel color="Color3.fromRGB(255, 0, 0)">TextLabel Example</textlabel>
```

## ImageLabel
Creates a **ImageLabel** in the embed frame.

### Properties
---
* OnHover `Function`: Returns/sets the function for whenever the **ImageLabel** is hovered over.
* Image `String`: Returns/sets the image for the **ImageLabel**.
* Color `Color3`: Returns/sets the color button.
* Font `Enum.Font`: Returns/sets the text font.
 ```XML
<imagelabel color="Color3.fromRGB(255, 0, 0)"></imagelabel>
```

## Examples

```XML
<embed color="Color3.ffromRGB(255, 0, 0)" width="500">
    <textlabel color="Color3.fromRGB(85, 85, 85)">I fucked your mom</textlabel>
    <button onclick="function(from) print(from, ' pressed yes') end" size="UDim2.new()">Yes</button>
     <button onclick="function(from) print(from, ' pressed no') end" size="UDim2.new()">No</button>
</embed>
```
