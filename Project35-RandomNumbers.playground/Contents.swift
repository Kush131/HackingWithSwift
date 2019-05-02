import UIKit
import GameplayKit

var str = "Hello, playground"

// Some example random generation post Swift 4.2

let intRandom = Int.random(in: 0...100)
let intRandomNonInclusive = Int.random(in: 0..<10)
let double = Double.random(in: 1000...10000)
let float = Float.random(in: -100...100)

// The old random number generator (pre Swift 4.2). I used this in production! Gives a random unsigned Int

let oldRandom = arc4random()

// If you wanted a range, you would use this... but it was problamatic due to modulo bias

let moduloBias = arc4random() % 4 // Results in either 0, 1, 2, or 3 if arc4Random has a max of 4

/* Modulo bias is the idea that you believe the results would be evenly distributed by 25%
 over each possible number, but the reality is it isn't evenly distributed. Example:

 0 % 4 = 0 - 20%
 1 % 4 = 1 - 20%
 2 % 4 = 2 - 20%
 3 % 4 = 3 - 20%
 4 % 4 = 0 - 20% + 20% from 0 above = 40%

 The reality is you're likely to get 0 40% of the time and the rest of the numbers 20% of the time.
 */

// There is a way to generate in a range the correct way with arc4Random...
let noModuloBias = arc4random_uniform(6)

// ...But this can still be ugly if you don't want a range from min of zero.

func RandomInt(min: Int, max: Int) -> Int {
    if max < min { return min }
    return Int(arc4random_uniform(UInt32(max-min) + 1)) + min
}

// With all of this being said, there is an Apple specific GameplayKit you can use to generate random
// numbers as well.

GKRandomSource.sharedRandom().nextInt()

// This will use the systems shared random number source to provide you an Integer at execution time.
// The range is from Int.min to Int.max, so it isn't unsigned by default (so not a direct arc4Random
// replacement). However, you can upper bound this by using the upperBound method (non-inclusive)

GKRandomSource.sharedRandom().nextInt(upperBound: 10)

// You can also use nextBool and even nextUniform for floating point numbers.

GKRandomSource.sharedRandom().nextBool()
GKRandomSource.sharedRandom().nextUniform()

// All of these methods are great if you just need a random number, but they are not great if you're
// looking for something deterministic. There are multiple options for that for various performance
// levels

let linearCongruential = GKLinearCongruentialRandomSource() // Low random, high performance
linearCongruential.nextInt(upperBound: 20)

let arc4 = GKARC4RandomSource() // Medium random, medium performance
arc4.nextInt(upperBound: 20)

let mersenne = GKMersenneTwisterRandomSource() // High random, low performance
mersenne.nextInt(upperBound: 20)

// Apple recommends you flush the arc4 generator before you use it or else the beginning sequences can
// be guessed. Dropping the first 769 values is recommended.

arc4.dropValues(1024)

// While this is all great, we could be doing most of this stuff with Swift natively. Apple provides
// some built in fun libraries for us to use in GameplayKit like...

// D6 Dice
let d6 = GKRandomDistribution.d6()
d6.nextInt()

// D20 Dice
let d20 = GKRandomDistribution.d20()
d20.nextInt()

// Custom crazy dice
let crazyDice = GKRandomDistribution(forDieWithSideCount: 11539)
crazyDice.nextInt()

// These all use default choices for random number creation, but you can also specity what method you want
// to use.

let random = GKMersenneTwisterRandomSource()
let distribution = GKRandomDistribution(randomSource: random, lowestValue: 0, highestValue: 10)
distribution.nextInt()

// Sometimes you might want true randomness, but other times you might want your randomness to form a trend
// like a bell curve or make sure sequences don't repeat often. GamplayKit provides those for us!

// Provides a predicable distribution over 1 to 6
let shuffled = GKShuffledDistribution.d6()
shuffled.nextInt()
shuffled.nextInt()
shuffled.nextInt()
shuffled.nextInt()
shuffled.nextInt()
shuffled.nextInt()
// These will literally produce 1 through 6, just in a random order.

// If we want a bell curve, we can use a GaussianDistribution
let gaussian = GKGaussianDistribution.init(forDieWithSideCount: 6)
gaussian.nextInt()

// This will produce the "average" case (between 1 to 6, it would be 3 and 4) more often
// than the tails of the distribution.

// So that's a lot of cool stuff... But where else do we see randomness in Swift? One way is during array shuffling

extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - 1))) + i
            swapAt(i, j)
        }
    }
}

// There is a built in GameplayKit method that does this for us (it does return a new array instead of mutating though).
let lotteryBalls = [Int](1...49)
let shuffledBalls = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lotteryBalls)

// One of the advantages of GamplayKit's randomness is that it is determinsitic across devices, so you could use it for
// a mobile lottery app over the network if you seed the random number generator.

// Create a MersenneTwister that is deterministic. As long as you give seed 100, you will always get the same random order.
let deterministicMersenne = GKMersenneTwisterRandomSource(seed: 100)




