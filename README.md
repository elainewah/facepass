##FacePass: The World's Easiest Two-Factor Authentication

Tired of typing out lengthy passwords on a phone screen, waiting on texts with authorization codes, and always having to keep your token generator on hand?

Introducing **FacePass**, which makes keeping your data secure as fun as taking a selfie!

Unlike current two-factor authentication methods, **FacePass** relies on the combination of:
- An _inherence factor_, in the form of facial recognition technologies to provide biometric identity verification, in addition to
- A _knowledge factor_, in the form of a unique password comprised of selecting a facial feature known only to the user.

We utilize state-of-the-art cloud-based face algorithms from Microsoft's [Project Oxford] (https://www.projectoxford.ai/face) to detect and recognize a human face from an image taken on your iPhone.

We also store a photo-based password based on a user's tap on a location relative to their face (e.g. left eye, nose, center of mouth). Our system is also robust to cases in which the user's face is in different locations or is different sizes in the image.

In addition, since our photo password is based on a facial feature rather than locations on a static image, **FacePass** is significantly less susceptible to the so-called [smudge attack] (http://static.usenix.org/event/woot10/tech/full_papers/Aviv.pdf).
