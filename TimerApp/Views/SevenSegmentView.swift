//
//  SevenSegmentView.swift
//  IntervalTimer
//
//  Pure Canvas-drawn 7-segment LED digits for authentic retro timer look.
//

import SwiftUI

// MARK: - Seven-Segment LED Display

struct SevenSegmentView: View {
    let text: String
    var digitColor: Color = .white
    var offColor: Color = .white.opacity(0.06)
    var digitHeight: CGFloat = 90

    //  Segment layout:
    //   ─ a ─       Bit order: a b c d e f g
    //  f     b       (bit 6 = a … bit 0 = g)
    //   ─ g ─
    //  e     c
    //   ─ d ─

    private static let seg: [Character: UInt8] = [
        "0": 0b1111110, "1": 0b0110000, "2": 0b1101101,
        "3": 0b1111001, "4": 0b0110011, "5": 0b1011011,
        "6": 0b1011111, "7": 0b1110000, "8": 0b1111111,
        "9": 0b1111011,
    ]

    private var dw: CGFloat { digitHeight * 0.55 }
    private var cw: CGFloat { digitHeight * 0.22 }
    private var sp: CGFloat { digitHeight * 0.06 }
    private var t: CGFloat  { digitHeight * 0.1 }

    var body: some View {
        Canvas { ctx, size in
            let chars = Array(text)
            var totalW: CGFloat = 0
            for ch in chars { totalW += (ch == ":" ? cw : dw) }
            totalW += CGFloat(max(0, chars.count - 1)) * sp
            let sx = (size.width - totalW) / 2
            let sy = (size.height - digitHeight) / 2
            var x = sx
            for ch in chars {
                if ch == ":" {
                    drawColon(ctx: ctx, x: x, y: sy)
                    x += cw + sp
                } else {
                    drawDigit(ctx: ctx, bits: Self.seg[ch] ?? 0, x: x, y: sy)
                    x += dw + sp
                }
            }
        }
        .frame(height: digitHeight)
    }

    private func drawColon(ctx: GraphicsContext, x: CGFloat, y: CGFloat) {
        let ds = t * 1.1; let cx = x + cw / 2
        let y1 = y + digitHeight * 0.30; let y2 = y + digitHeight * 0.70
        ctx.fill(Circle().path(in: CGRect(x: cx - ds/2, y: y1 - ds/2, width: ds, height: ds)),
                 with: .color(digitColor))
        ctx.fill(Circle().path(in: CGRect(x: cx - ds/2, y: y2 - ds/2, width: ds, height: ds)),
                 with: .color(digitColor))
    }

    private func drawDigit(ctx: GraphicsContext, bits: UInt8, x: CGFloat, y: CGFloat) {
        let ht = t / 2; let ins = t * 0.15; let mid = digitHeight / 2; let w = dw; let h = digitHeight
        // a: top
        seg(ctx: ctx, on: bits & 0b1000000 != 0, pts: [
            .init(x: x+ins+t, y: y), .init(x: x+w-ins-t, y: y),
            .init(x: x+w-ins-t-ht, y: y+t), .init(x: x+ins+t+ht, y: y+t)])
        // b: top-right
        seg(ctx: ctx, on: bits & 0b0100000 != 0, pts: [
            .init(x: x+w, y: y+ins+t), .init(x: x+w, y: y+mid-ins),
            .init(x: x+w-t, y: y+mid-ins-ht), .init(x: x+w-t, y: y+ins+t+ht)])
        // c: bottom-right
        seg(ctx: ctx, on: bits & 0b0010000 != 0, pts: [
            .init(x: x+w, y: y+mid+ins), .init(x: x+w, y: y+h-ins-t),
            .init(x: x+w-t, y: y+h-ins-t-ht), .init(x: x+w-t, y: y+mid+ins+ht)])
        // d: bottom
        seg(ctx: ctx, on: bits & 0b0001000 != 0, pts: [
            .init(x: x+ins+t+ht, y: y+h-t), .init(x: x+w-ins-t-ht, y: y+h-t),
            .init(x: x+w-ins-t, y: y+h), .init(x: x+ins+t, y: y+h)])
        // e: bottom-left
        seg(ctx: ctx, on: bits & 0b0000100 != 0, pts: [
            .init(x: x, y: y+mid+ins), .init(x: x+t, y: y+mid+ins+ht),
            .init(x: x+t, y: y+h-ins-t-ht), .init(x: x, y: y+h-ins-t)])
        // f: top-left
        seg(ctx: ctx, on: bits & 0b0000010 != 0, pts: [
            .init(x: x, y: y+ins+t), .init(x: x+t, y: y+ins+t+ht),
            .init(x: x+t, y: y+mid-ins-ht), .init(x: x, y: y+mid-ins)])
        // g: middle
        seg(ctx: ctx, on: bits & 0b0000001 != 0, pts: [
            .init(x: x+ins+t, y: y+mid), .init(x: x+ins+t+ht, y: y+mid-ht),
            .init(x: x+w-ins-t-ht, y: y+mid-ht), .init(x: x+w-ins-t, y: y+mid),
            .init(x: x+w-ins-t-ht, y: y+mid+ht), .init(x: x+ins+t+ht, y: y+mid+ht)])
    }

    private func seg(ctx: GraphicsContext, on: Bool, pts: [CGPoint]) {
        guard let f = pts.first else { return }
        var p = Path()
        p.move(to: f); for pt in pts.dropFirst() { p.addLine(to: pt) }; p.closeSubpath()
        ctx.fill(p, with: .color(on ? digitColor : offColor))
    }
}

/// Returns either SevenSegmentView or standard Text based on font selection.
@ViewBuilder
func timerDigitsView(
    text: String, font: TimerNumberFont, size: CGFloat,
    color: Color, weight: Font.Weight = .bold
) -> some View {
    if font.isSevenSegment {
        SevenSegmentView(text: text, digitColor: color,
                         offColor: color.opacity(0.06), digitHeight: size)
    } else {
        Text(text)
            .font(.system(size: size, weight: weight, design: font.design))
            .monospacedDigit().foregroundColor(color)
            .contentTransition(.numericText())
    }
}
