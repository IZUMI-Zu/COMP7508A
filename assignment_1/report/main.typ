#import "@preview/kunskap:0.1.0": *

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

Tested CCD IK with varying configurations:

- *Target position:* [0.5, 0.75, 0.5]
- *End effector:* lWrist_end (left wrist)
- *Variables:* iteration count, start joint

=== Results Comparison Table


#figure(
  table(
    columns: 6,
    align: (center, center, center, center, center, center, center),
    fill: (x, y) => if y == 0 { rgb("2563eb").lighten(85%) } 
                     else if calc.odd(y) { rgb("f0f9ff") },
    stroke: 0.5pt + rgb("94a3b8"),
    
    // Header row with bold text
    table.header(
      [*Config*],
      [*Start Joint*],
      [*End Joint*],
      [*Iterations*],
      [*Distance Error*],
      [*Visual Quality*],
    ),
    
    // Data rows
    [A], [RootJoint], [lWrist_end], [5], [0.0279], [Good],
    [B], [RootJoint], [lWrist_end], [20], [0.0052], [Excellent],
    [C], [RootJoint], [lWrist_end], [100], [0], [Excellent],
    [D], [lToeJoint_end], [lWrist_end], [20], [0], [Excellent (More DOF)],
    [E], [lShoulder], [lWrist_end], [20], [0.3867], [Failed (unreachable)],
  ),
  caption: [Performance comparison of different IK configurations],
  kind: table,
) <tab:ik-performance>


=== Configuration A: Root → lWrist (5 iterations)


#figure(
  image("./img/ass1/9.png", height: 30%),
  caption: [Limited iterations result in error]
)

With only 5 iterations, the CCD algorithm doesn't have enough cycles to fully converge. Each iteration adjusts joints from end to root, but 5 passes are insufficient to propagate corrections through the entire chain.

=== Configuration B: Root → lWrist (20 iterations)

#figure(
  image("./img/ass1/8.png", height: 30%),
  caption: [20 iterations achieve good convergence]
)

With 20 iterations, the algorithm achieves strong convergence. The chain provides enough degrees of freedom to reach the target while maintaining natural body proportions.

=== Configuration D: lToe → lWrist (20 iterations)

#figure(
  image("./img/ass1/10.png", height: 30%),
  caption: [Starting from toe creates unnatural lower body pose]
)

- Chain: lToeJoint_end → toe → ankle → knee → hip → RootJoint → pelvis → torso → shoulder → elbow → wrist → lWrist_end (13 joints)
- Iterations: 20

=== Configuration E: lShoulder → lWrist (20 iterations)

#figure(
  image("./img/ass1/11.png", height: 30%),
  caption: [Shorter chain converges faster with better local control]
)

The algorithm converges to the closest possible configuration (arm fully extended toward target), but physics prevents reaching the goal. The error of 38.67cm represents the unreachable gap.

// === Analysis

// *Effect of Iteration Count:*
// - 10 iterations: Fast but inaccurate (~2.3cm error)
// - 20 iterations: Balanced accuracy vs speed (~0.5cm error)
// - 100 iterations: Minimal improvement over 50 (diminishing returns)

// *Effect of Start Joint:*
// - *Full chain (Root):* Most flexible but slower convergence, affects whole body
// - *Partial chain (lShoulder):* Faster, more stable, isolated arm movement
// - *Cross-chain (lToe):* Produces unnatural poses due to competing constraints

// *Recommended settings:*
// - General manipulation: Start from shoulder joint, 30-50 iterations
// - Full-body reach: Start from root, 50-100 iterations
// - Real-time interaction: Limit to 20 iterations, accept higher error
