public class CodeReview {
    public double GetAverage(int[] scores) {
        int total = 0;
        foreach (var s in scores) total += s;
        // Divide-by-zero if scores is empty
        return total / scores.Length;
    }
}