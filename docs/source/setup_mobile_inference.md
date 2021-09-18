### Introduction

We will discuss how to setup mobile inferencing after we have trained our tensorflow object detection model and converted it to a mobile optimized version.

Let's say the saved mobile optimized model is saved in a directory called `web_model`. We will work with included`tfjs_object_detect` setup to add in configuration edits, setup `npm` packages and start it to complete our mobile inferencing solution. The setup `tfjs_object_detect` is mostly taken from [Real-time object detection in the browser using TensorFlow.js](https://github.com/hugozanini/TFJS-object-detection) with edits made in `src/index.js` and the steps listed in this article is heavily inspired from the same. So, it's highly recommended to take a look there.

### Setup `npm`

`cd` to `tfjs_object_detect/`. Then from console, run -

```shell
npm install
npm outdated npx npm-check-updates -u
```
Second step is to update packages. More info could be found here - [Upgrading npm dependencies](https://www.carlrippon.com/upgrading-npm-dependencies/).

### Setup `index.js`

We need to host the converted model somewhere and link it in `src/index.js`. We have two options :
- Local : cd to `web_model` and run `http-server -c1 --cors .` Thus, model would be available at `http://127.0.0.1:8080`. This a good choice when you want to keep the model weights in a safe place and control who can request inferences to it. Downside is, if you are using a public domain like `ngrok`, the model won't be accessible.
- Github hosting :  Upload all the files in `web_model` onto a github repo and link up the raw github link of `model.json`. This way, model would be accessible on public domains. The link would be something like - `https://raw.githubusercontent.com/[repo]/model.json`.

**Step #1 : ** Setup `model` and feature-label


Look in `src/index.js`, for `Edit section` that needs edits.

- Set `model_json_path` to point to the path that holds `model.json`, like so -


```javascript
// Option-1 : local host for local testing (won't work on public url)
const model_json_path = "http://127.0.0.1:8080/model.json"

// or ..

// Option-2 : github host for public domains
const model_json_path = "https://raw.githubusercontent.com/[repo]/model.json"
````

- Set `feature_label` to the feature label in use.

Note again, that for now this setup only works with one-class training.

**Step #2 : ** Setup IDs for `boxes`, `scores` and `classID` in `src/index.js`

Edit `src/index.js` :

```javascript
const DEBUG_PREDICTIONS = true;
```

From console, run -
```shell
npm start
```

This will start inferencing app on `localhost:3000`. With `DEBUG_PREDICTIONS` set as `true`, it will exit out after printing predictions for the first object. Our task is to identify  IDs for `boxes`, `scores` and `classID` from the developer console after run.

Console output would something like this (barring the actual values) :
```shell
============================ Debug for predictions : index.js:124
Predictions[0] index.js:126
undefined index.js:127
Predictions[1] index.js:126
Array(4) [ -0.033198282122612, -0.03233614191412926, 0.06762800365686417, 0.06828981637954712 ]
index.js:127
Predictions[2] index.js:126
Array(4) [ 0.001329183578491211, 0, 1, 0.9709863662719727 ]
index.js:127
Predictions[3] index.js:126
Array [ 0.006459423806518316, 0.007140422705560923 ]
index.js:127
Predictions[4] index.js:126
0.9996019005775452 index.js:127
Predictions[5] index.js:126
Array [ 0.0019781405571848154, 0.9996019005775452 ]
index.js:127
Predictions[6] index.js:126
12673 index.js:127
Predictions[7] index.js:126
1
```

Let's investigate how to identify our IDs.

(1) boxes ID : We are looking for `Array(4) ` that has all positive values. So, here it would be -

```
Predictions[2] index.js:126
Array(4) [ 0.001329183578491211, 0, 1, 0.9709863662719727 ]
```
Hence, `ID = 2`.

(2) scores ID : We are looking for a float value. So -
```
Predictions[4] index.js:126
0.9996019005775452 index.js:127
```
Hence, `ID = 4`.

(3) classes ID : We are looking for an int value. Since, we are working with one-class solution, so look for `1` -
```
Predictions[7] index.js:126
1
```
Hence, `ID = 7`.

Once, we have the IDs, edit `src/index.js` with those :

```javascript
const DEBUG_PREDICTIONS = false;

const pred_boxes_ID   = 2;
const pred_scores_ID  = 4;
const pred_classes_ID = 7;
```

From console, run -
```shell
npm start
```

### Broadcast on public URL
Broadcast inferencing on public url with `ngrok` @ same port with - `ngrok http 3000`, assuming the `npm` server was @ `3000`. The public url could then be accessed on a mobile for mobile based inferences thereafter. To specify region, for example `India`, run : `ngrok http 3000 -region=in`.

