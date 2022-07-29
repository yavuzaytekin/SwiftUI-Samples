//
//  ContentView.swift
//  tic-tac-toe
//
//  Created by Yavuz Aytekin on 21.07.2022.
//

import SwiftUI

//MARK: Enums
enum BoardState {
    case none
    case O
    case X
    case winner

    func getChar() -> String {
        switch self {
        case .none: return ""
        case .O: return "O"
        case .X: return "X"
        case .winner: return "winner"
        }
    }
}

enum WinnerLine{
    case upToDown
    case leftToRight
    case leftToRightCross
    case rightToLeftCross
}

//MARK: - Views
struct GameView: View {
    @State var isXTurn: Bool = false
    @State var isGameFinished: Bool = false
    @State var winnerLine: WinnerLine = .upToDown

    @State var gameBoard: [[BoardState]] =
    [
        [.none, .none, .none],
        [.none, .none, .none],
        [.none, .none, .none]
    ]

    var body: some View {
        VStack(alignment: .center,
               spacing: 100) {
            let turnChar = isXTurn ? BoardState.X.getChar() : BoardState.O.getChar()

            Text(isGameFinished ? (isXTurn ? "X Wins!" : "O Wins!") : "\(turnChar) turn")
                .bold()
                .font(.system(size: 48))
            VStack {
                ForEach(0..<3) { x in
                    HStack {
                        ForEach(0..<3) { y in
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 100, height: 100)
                                    .onTapGesture {
                                        if gameBoard[x][y] == BoardState.none {
                                            play(x: x, y: y)
                                        }
                                    }
                                Text(gameBoard[x][y].getChar() == "winner" ? (isXTurn ? "X" : "O") : gameBoard[x][y].getChar())
                                    .bold()
                                    .font(.system(size: 32))

                                if gameBoard[x][y] == .winner {
                                    getLine(with: winnerLine)
                                        .stroke(.red, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                                        .frame(width: 100, height: 100)
                                }
                            }
                        }
                    }
                }
            }
            .background(Color.black)
            .alert("Game Finished. \(isXTurn ? "X Wins!" : "O Wins!")", isPresented: $isGameFinished) {
                Button("Restart") {
                    restart()
                }
            }
        }
    }
}

//MARK: - Game Functions
extension GameView {
    func play(x: Int, y: Int) {
        gameBoard[x][y] = isXTurn ? .X : .O
        checkGameBoard()
        if !isGameFinished {
            isXTurn = !isXTurn
        }
    }

    func checkGameBoard() {
        for x in 0..<3 {
            if gameBoard[x][0] != .none &&
                gameBoard[x][0] == gameBoard[x][1] &&
                gameBoard[x][0] == gameBoard[x][2] {

                gameBoard[x][0] = .winner
                gameBoard[x][1] = .winner
                gameBoard[x][2] = .winner
                winnerLine = .leftToRight
                isGameFinished = true
            }

            if gameBoard[0][x] != .none &&
                gameBoard[0][x] == gameBoard[1][x] &&
                gameBoard[0][x] == gameBoard[2][x] {

                gameBoard[0][x] = .winner
                gameBoard[1][x] = .winner
                gameBoard[2][x] = .winner
                winnerLine = .upToDown
                isGameFinished = true
            }

            if x + 2 <= 2 {
                if gameBoard[x][x] != .none &&
                    gameBoard[x][x] == gameBoard[x + 1][x + 1] &&
                    gameBoard[x][x] == gameBoard[x + 2][x + 2] {

                    gameBoard[x][x] = .winner
                    gameBoard[x + 1][x + 1] = .winner
                    gameBoard[x + 2][x + 2] = .winner
                    winnerLine = .leftToRightCross
                    isGameFinished = true
                }
            }

            if x - 2 >= 0 {
                if gameBoard[x - 2][x] != .none &&
                    gameBoard[x - 2][x] == gameBoard[x - 1][x - 1] &&
                    gameBoard[x - 2][x] == gameBoard[x][x - 2] {

                    gameBoard[x - 2][x] = .winner
                    gameBoard[x - 1][x - 1] = .winner
                    gameBoard[x][x - 2] = .winner
                    winnerLine = .rightToLeftCross
                    isGameFinished = true
                }
            }
        }
    }

    func restart() {
        gameBoard =
        [
            [.none, .none, .none],
            [.none, .none, .none],
            [.none, .none, .none]
        ]
        isXTurn = false
        isGameFinished = false
    }
}

//MARK: - Utils
extension GameView {
    func getLine(with winnerLine: WinnerLine) -> Line {
        return Line(winnerLine: winnerLine)
    }
}

//MARK: - Line
struct Line: Shape {
    let winnerLine: WinnerLine

    init(winnerLine: WinnerLine) {
        self.winnerLine = winnerLine
    }

    func path(in rect: CGRect) -> Path {
        let path: Path

        switch winnerLine {
        case .upToDown:
            path = UpToDownLinePath().getLinePath(in: rect)
        case .leftToRight:
            path = LeftToRightLinePath().getLinePath(in: rect)
        case .leftToRightCross:
            path = LeftToRightCrossLinePath().getLinePath(in: rect)
        case .rightToLeftCross:
            path = RightToLeftCrossLinePath().getLinePath(in: rect)
        }

        return path
    }
}

//MARK: - Line Paths
protocol LinePath {
    func getLinePath(in rect: CGRect) -> Path
}

struct LeftToRightCrossLinePath: LinePath {
    func getLinePath(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

        return path
    }
}

struct RightToLeftCrossLinePath: LinePath {
    func getLinePath(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        return path
    }
}

struct UpToDownLinePath: LinePath {
    func getLinePath(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))

        return path
    }
}

struct LeftToRightLinePath: LinePath {
    func getLinePath(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))

        return path
    }
}
