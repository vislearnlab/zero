% Make a CSV file with object names & object descriptions (~150 words, AI
% generated)

% Create a structure with object descriptions
descriptions = struct();

descriptions.stethoscope = "A medical instrument used by healthcare professionals to listen to internal sounds in the body, particularly heart and lung sounds. It consists of a chest piece with a diaphragm that captures sound waves, connected to rubber tubing that channels these sounds to earpieces. The diaphragm vibrates with body sounds, which are amplified through the hollow tubing. Modern stethoscopes often feature both a bell (for low frequencies) and a diaphragm (for high frequencies), allowing doctors to hear different types of body sounds by simply rotating the chest piece.";

descriptions.french_press = "A manual coffee brewing device invented in the 1920s, consisting of a cylindrical beaker, a lid with a plunger, and a fine metal mesh filter. Coffee is brewed by steeping coarse coffee grounds in hot water for several minutes, then slowly pressing down the plunger to separate the grounds from the liquid. The mesh filter allows the coffee oils and fine particles to pass through while trapping the grounds, resulting in a full-bodied, rich coffee with more oils than paper-filtered methods.";

descriptions.shoe_horn = "A tool designed to aid in putting on shoes without crushing the heel counter. Typically made of plastic, metal, or wood, it features a long, curved surface that acts as a smooth ramp for the heel to slide down into the shoe. The curved design reduces friction and prevents damage to the shoe's heel structure. Long-handled versions help users avoid bending over, making them particularly useful for elderly individuals or those with limited mobility.";

descriptions.fishing_reel = "A mechanical device attached to a fishing rod that stores, releases, and retrieves fishing line. It uses a complex system of gears, bearings, and a rotating spool to manage line tension and control. Modern reels often feature drag systems that prevent line breakage by allowing controlled line release when a fish pulls strongly. Different types (spinning, baitcasting, fly) serve various fishing techniques and conditions.";

descriptions.crank_flashlight = "A self-powered illumination device that converts mechanical energy into electrical energy, requiring no batteries. It contains a small generator connected to a hand crank mechanism. When the crank is turned, it spins a magnet inside wire coils, generating electrical current through electromagnetic induction. This powers an LED bulb and often charges a small capacitor or battery for short-term energy storage. One minute of cranking typically provides several minutes of light.";

descriptions.rolodex = "A rotating file device used to store and organize contact information, popular in offices before digital contact management. It consists of a wheel-like mechanism holding specially notched cards that can be flipped through for quick access. Cards are alphabetically arranged and can be easily added, removed, or updated. The distinctive design allows users to quickly scroll through contacts by rotating the wheel, while the notched cards stay in place.";

descriptions.floppy_disk = "A portable data storage device popular from the 1970s through early 2000s. It consists of a magnetic disk enclosed in a protective plastic case. The disk spins inside while a read/write head accesses data through an exposed section. Standard 3.5-inch disks typically stored 1.44 MB of data. Despite their limited capacity by modern standards, they revolutionized personal computing by providing an easy way to transfer files between computers and create backups.";

descriptions.bulb_planter = "A specialized gardening tool designed for efficiently planting flower bulbs at the correct depth. It features a cylindrical cutting edge that removes a plug of soil when pushed into the ground and twisted. Most models have depth markings and a release mechanism to deposit the soil back over the bulb. Some versions include long handles to reduce back strain. The tool ensures consistent planting depth, which is crucial for proper bulb growth and flowering.";

descriptions.three_hole_punch = "An office tool used to create uniform holes in paper for storage in ring binders. It uses a lever mechanism that drives metal punches through paper, creating three evenly-spaced holes. The punches compress and cut the paper against a die, while a confetti tray catches the paper circles. Most models include paper guides and adjustable punch patterns. Heavy-duty versions can punch through dozens of sheets simultaneously.";

descriptions.pocket_radio = "A portable, compact radio receiver that can be carried in a pocket. It uses electronic circuits to capture and convert radio waves into audio signals. Most models feature AM/FM bands, a telescoping antenna for better reception, and a small speaker or headphone jack. Early transistor versions revolutionized personal electronics in the 1950s by allowing people to listen to broadcasts anywhere. Modern versions often include digital tuning and preset stations.";

descriptions.hand_mixer = "A manual kitchen tool used for beating, whipping, and blending ingredients without electricity. It consists of a hand crank that, when turned, rotates a set of metal beaters or whisks through a gear mechanism. The gears convert the rotary motion of the handle into faster rotation of the beaters, allowing for efficient mixing with manual power. Often made of stainless steel with a comfortable grip handle, these mixers are particularly useful for whipping cream, beating eggs, or mixing batters in situations without electricity. Some models feature interchangeable beaters and adjustable speeds through different gear ratios.";

descriptions.blood_pressure_cuff = "A medical device used to measure blood pressure, consisting of an inflatable cuff connected to a pressure gauge or electronic sensor. The cuff wraps around the upper arm and is inflated to temporarily stop blood flow. As it slowly deflates, it measures systolic and diastolic pressure using either audio detection of blood flow (manual) or oscillometric detection (automated). Modern digital versions often include memory functions and irregular heartbeat detection.";

% Get field names and descriptions
object_names = fieldnames(descriptions);
description_texts = cellfun(@(x) descriptions.(x), object_names, 'UniformOutput', false);

% Create table
T = table(object_names, description_texts, 'VariableNames', {'object_name', 'description'});

% Write to CSV
output_dir = [userpath '/zero/experiment/'];
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

writetable(T, fullfile(output_dir, 'object_descriptions.csv'));
fprintf('Descriptions have been saved to %s\n', fullfile(output_dir, 'object_descriptions.csv')); 