import Foundation
import SwiftUI

struct YaamavaEntryScreen: View {
    @StateObject private var loader: YaamavaWebLoader

    init(loader: YaamavaWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            YaamavaWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                YaamavaProgressIndicator(value: percent)
            case .failure(let err):
                YaamavaErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                YaamavaOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct YaamavaProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            YaamavaLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct YaamavaErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct YaamavaOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
