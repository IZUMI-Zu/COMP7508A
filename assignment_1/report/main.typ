#import "@preview/kunskap:0.1.0": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#show: codly-init.with()

#show: kunskap.with(
    title: [Assignment 1's Report],
    author: "ZU BINSHUO\nUID: 3036657457",
    header: "COMP7508A",
    date: datetime.today().display("[month repr:long] [day padding:zero], [year repr:full]"),

    // Paper size, fonts, and colors can optionally be customized as well

    // Paper size
    paper-size: "a4",

    // Fonts
    body-font: ("Noto Serif"),
    body-font-size: 10pt,
    raw-font: ("Hack Nerd Font", "Hack NF", "Hack", "Source Code Pro"),
    raw-font-size: 9pt,
    headings-font: ("Source Sans Pro", "Source Sans 3"),

    // Colors
    link-color: link-color,
    muted-color: muted-color,
    block-bg-color: block-bg-color,
)

== Task 1 - Character Animation Video

=== Animation Design

Created a 5-second animation of a humanoid character performing a walk-jump-walk sequence (30fps = 150 frames total):

- *Frames 1-30 (0-1s):* Walking forward

- *Frames 31-120 (1-4s):* Jump sequence

  - Frames 31-55: Crouch preparation
  - Frames 56-70: Jump upward
  - Frames 71-90: Mid-air pose
  - Frames 91-115: Landing
  
- *Frames 116-150 (4-5s):* Continue walking

=== Skeleton Structure

- *Root Joint:* Pelvis

- *Main Chains:*

  - Spine → Chest → Neck → Head (5 joints)
  - Left/Right Shoulder → Elbow → Wrist (4 joints each)
  - Left/Right Hip → Knee → Ankle (5 joints each)

- *Total Joints:* 19

=== Screenshots

#figure(
  image("./img/ass1/1.png", height: 40%),
  caption: [Skeleton rigging in Blender]
)

#figure(
  image("./img/ass1/2.png"),
  caption: [Keyframe timeline]
)


#figure(
  image("./img/ass1/3.png", height: 30%),
  caption: [Final rendered frame with lighting]
)


== Task 2

=== Part 1: T-Pose Visualization

*Implementation approach:*

- Traversed skeleton hierarchy from root joint
- Applied parent-to-child offset vectors recursively
- Computed global positions by accumulating local offsets

#figure(
  image("./img/ass1/4.png", height: 30%),
  caption: [T-Pose with skeleton]
)

#figure(
  image("./img/ass1/5.png", height: 30%),
  caption: [T-Pose with skeleton]
)

*Observations:*

- Root joint positioned at origin
- Symmetric arm extension along X-axis
- Total of 31 joints visualized correctly

=== Part 2: Forward Kinematics Animation

*Implementation approach:*

- For each frame, applied local rotations from BVH data
- Multiplied parent orientation with local rotation (quaternion multiplication)
- Rotated offset vectors by accumulated orientation
- Added to parent position to get child global position

#figure(
  image("./img/ass1/6.png", height: 30%),
  caption: [Walking motion]
)

#figure(
  image("./img/ass1/7.png", height: 30%),
  caption: [Walking motion]
)

== Task 3

=== Experiment Setup

This section systematically evaluates the CCD (Cyclic Coordinate Descent) IK algorithm across four key dimensions:

1. *Iteration Count:* Testing convergence behavior (5, 20, 100 iterations)
2. *Start Joint:* Varying chain length and complexity (RootJoint, lToeJoint_end, rToeJoint_end, lShoulder)
3. *End Joint:* Testing different end effectors (lWrist_end, rWrist_end)
4. *Target Position:* Evaluating reachability in different spatial regions

*Skeleton Structure Analysis:*
- Left arm length (shoulder to wrist): 0.601m
- Full chain length (RootJoint to lWrist_end): 1.070m (8 joints)
- Leg length (root to toe): 0.926m

=== Evaluation Metric

*Distance Error* is computed as the Euclidean distance (L2 norm) between the final end-effector position and the target position:

$ "Error" = norm(bold(p)_("end") - bold(p)_("target")) = sqrt((x_("end") - x_("target"))^2 + (y_("end") - y_("target"))^2 + (z_("end") - z_("target"))^2) $

where:
- $bold(p)_("end") = [x_("end"), y_("end"), z_("end")]$ is the 3D position of the end effector after IK optimization
- $bold(p)_("target") = [x_("target"), y_("target"), z_("target")]$ is the desired target position

*Implementation (Python):*
#codly(languages: codly-languages)
```python
# Compute L2 norm of position difference vector
final_distance = np.linalg.norm(chain_positions[end_idx] - target_pose)
```

*Success Criteria:*
- Error < 0.01m (1cm): Excellent convergence
- Error < 0.05m (5cm): Acceptable for most applications
- Error > 0.10m (10cm): Poor convergence or unreachable target

=== Results Comparison Table

#figure(
  table(
    columns: 7,
    align: (center, center, center, center, center, center, center),
    fill: (x, y) => if y == 0 { rgb("2563eb").lighten(85%) }
                     else if calc.odd(y) { rgb("f0f9ff") },
    stroke: 0.5pt + rgb("94a3b8"),

    // Header row with bold text
    table.header(
      [*Config*],
      [*Start Joint*],
      [*End Joint*],
      [*Target Position*],
      [*Iterations*],
      [*Distance Error (m)*],
      [*Result*],
    ),

    // Group 1: Iteration count effect
    [A], [RootJoint], [lWrist_end], [[0.5, 0.75, 0.5]], [5], [0.0279], [Partial],
    [B], [RootJoint], [lWrist_end], [[0.5, 0.75, 0.5]], [20], [0.0052], [Good],
    [C], [RootJoint], [lWrist_end], [[0.5, 0.75, 0.5]], [100], [0.0000], [Perfect],

    // Group 2: Chain structure effect
    [D], [lToeJoint_end], [lWrist_end], [[0.5, 0.75, 0.5]], [20], [0.0000], [Success],
    [E], [rToeJoint_end], [lWrist_end], [[0.5, 0.75, 0.5]], [20], [0.0000], [Success],

    // Group 3: Different end effector
    [F], [RootJoint], [rWrist_end], [[-0.5, 0.75, 0.5]], [20], [0.0052], [Good],
  ),
  caption: [Comprehensive performance comparison across all test dimensions],
  kind: table,
) <tab:ik-performance>


=== Configuration A: 5 Iterations

#figure(
  image("./img/ass1/9.png", height: 30%),
  caption: [Insufficient iterations lead to convergence error (2.79cm)]
)

With only 5 iterations, the CCD algorithm cannot fully converge. Each iteration adjusts one joint in the chain from end to root, requiring multiple passes to propagate corrections through all 8 joints. The residual error of 2.79cm demonstrates incomplete optimization.

=== Configuration B: 20 Iterations (Baseline)

#figure(
  image("./img/ass1/8.png", height: 30%),
  caption: [Standard iteration count achieves good convergence (0.52cm error)]
)

With 20 iterations, the algorithm achieves strong convergence with 0.52cm error. This represents a practical balance between computational cost and accuracy for real-time applications.

=== Configuration C: 100 Iterations

With 100 iterations, the algorithm achieves perfect convergence (error ≈ 0.0cm). This demonstrates CCD's ability to reach precise solutions given sufficient iterations, though diminishing returns suggest 50-100 iterations is the practical upper limit.

=== Configuration D: Left Toe → Left Wrist

#figure(
  image("./img/ass1/10.png", height: 30%),
  caption: [Ultra-long chain produces surprisingly natural reaching pose]
)

*Chain composition:* lToeJoint_end → lToeJoint → lAnkle → lKnee → lHip → RootJoint → pelvis_lowerback → lowerback_torso → lTorso_Clavicle → lShoulder → lElbow → lWrist → lWrist_end (13 joints)

This ultra-long chain (13 joints) successfully reaches the target with *zero error* and produces a remarkably natural pose.

=== Configuration E: Right Toe → Left Wrist

#figure(
  image("./img/ass1/12.png", height: 30%),
  caption: [Cross-body chain from right toe to left wrist]
)

*Chain composition:* rToeJoint_end → rToeJoint → rAnkle → rKnee → rHip → RootJoint → pelvis_lowerback → lowerback_torso → lTorso_Clavicle → lShoulder → lElbow → lWrist → lWrist_end (13 joints, cross-body)

Starting from the *opposite* foot creates an asymmetric cross-body chain. The algorithm successfully solves this configuration (error ≈ 0.0cm), demonstrating CCD's robustness to chain topology. Unlike Config D (same-side chain), this cross-body configuration introduces torso rotation and asymmetric weight shift, mimicking how humans reach across their body.


=== Configuration F: Right Wrist End Effector

#figure(
  image("./img/ass1/13.png", height: 30%),
  caption: [Right wrist end effector with mirrored target position]
)

Using `rWrist_end` as the end effector with a mirrored target position `[-0.5, 0.75, 0.5]` tests algorithmic symmetry. The result (error ≈ 0.5cm) mirrors Config B's performance, confirming that CCD handles left/right chains equivalently.

