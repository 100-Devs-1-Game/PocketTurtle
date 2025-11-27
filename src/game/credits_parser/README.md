# Credits Parser

Displays game credits in a RichTextLabel from follwing sources:
- A text file containing the text from `/contributors export`. Will be displayed as main contributors in their respective categories.
- Additional text files from each component, provided as `component_credits.txt`. Will be displayed at the bottom under "Thanks to:"

# Required steps

- Attach script to a RichTextLabel
- Enable `Fit Content`
- Set a sufficient `Custom Minimum Size` width
- Use `/contributors export` in your game channel and copy the result
- Paste content into text file and drag it onto `Credits Path`
- Make sure your project export settings include *.txt in the non-resource filters
- Add the component_credits.txt of all components you are using from the 100DevsComponents Repository to `Component Credits` 
