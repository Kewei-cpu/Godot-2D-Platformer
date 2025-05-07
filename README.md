# Godot Fade Scene Transition

## Overview

This project shows how to easily setup a scene transition effect in which
when a scene loades it fades in and before loading the next scene the current 
fades out and the same process restats in the next scene. 

It was tested on **Godot 4.4.1**. It should work on some previous versions though.

# Setup
- After installing the plugin simply add the Node "FadeTransitionManager" as the 
last item of each scene.
- Set the "Next Scene" property of the "FadeTransitionManager" otherwise the node will
play the fade out animation, but the same scene will continue to be shown.
- You can set the length of the animation with the "Fade Length" property.

#Important Notes
- This version contemplates only the black color. Next versions will allow for overriding that.
- It propagates mouse input. 
- Future versions will be more customizable.

# Sequence Diagram
![sudden-fade-transition-sequence-diagram](https://github.com/user-attachments/assets/dc4096fe-1241-405c-ba34-d532305a6a05)


## Visual Sample

![godot-scene-transition](https://github.com/user-attachments/assets/927f6a43-c459-4aa9-a705-a1fa94940c8e)
