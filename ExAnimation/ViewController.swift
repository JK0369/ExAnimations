//
//  ViewController.swift
//  ExAnimation
//
//  Created by 김종권 on 2022/03/12.
//

import UIKit
import SnapKit

final class ViewController: UIViewController {
  private lazy var animationTargetView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemBlue
    self.view.addSubview(view)
    return view
  }()
  private lazy var pullDownButton: UIButton = {
    let button = UIButton()
    button.setTitle("옵션", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.setTitleColor(.blue, for: .highlighted)
    self.view.addSubview(button)
    return button
  }()
  override func viewDidLoad() {
    super.viewDidLoad()
    self.animationTargetView.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(16)
      $0.centerX.equalToSuperview()
      $0.size.equalTo(120)
    }
    self.pullDownButton.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(16)
      $0.right.equalToSuperview().inset(40)
    }
    
    let originAnimationAction = UIAction(
      title: "원상태로",
      handler: { _ in
        // autolayout 애니메이션 원상 복구
        self.animationTargetView.snp.remakeConstraints {
          $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(16)
          $0.centerX.equalToSuperview()
          $0.size.equalTo(120)
        }

        // 단일 keyframe 애니메이션 제거
        self.animationTargetView.layer.removeAnimation(forKey: "myAnimation")
        self.animationTargetView.layer.removeAnimation(forKey: "shaking")

        UIView.animate(
          withDuration: 0.5,
          animations: self.view.layoutIfNeeded
        )
      }
    )
    
    let autolayoutAnimationAction = UIAction(
      title: "autolayout 변화",
      handler: { _ in
        self.animationTargetView.snp.remakeConstraints {
          $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(-16)
          $0.centerX.equalToSuperview()
          $0.size.equalTo(240)
        }

        UIView.animate(
          withDuration: 0.5,
          animations: self.view.layoutIfNeeded
        )
      }
    )
    
    // 단일 애니메이션 (CAKeyframeAnimation): https://ios-development.tistory.com/841
    let singleKeyframeAnimationAction = UIAction(
      title: "단일 애니메이션 (CAKeyframeAnimation)",
      handler: { _ in
        let opacityKeyframe = CAKeyframeAnimation(keyPath: "opacity")
        opacityKeyframe.values = [0.2, 0.5, 0.2] // opacity값이 0.2 -> 0.5 -> 0.2로 바뀜 (선명해졌다가 다시 흐려지는 애니메이션)
        opacityKeyframe.keyTimes = [0, 0.5, 1]
        opacityKeyframe.duration = 1
        opacityKeyframe.repeatCount = .infinity
        self.animationTargetView.layer.add(opacityKeyframe, forKey: "myAnimation")
      }
    )
    let singleKeyframeAnimationSecondAction = UIAction(
      title: "단일 애니메이션 - 쉐이킹 (CAKeyframeAnimation)",
      handler: { _ in
        let shakingKeyframe = CAKeyframeAnimation(keyPath: "position.x")
        shakingKeyframe.values = [0, 5, -5, 5, 2, 2, -2, 0]
        shakingKeyframe.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1]
        shakingKeyframe.duration = 0.4
        shakingKeyframe.isAdditive = true // true이면 values가 현재 위치 기준, false이면 values가 Screen좌표 기준
        self.animationTargetView.layer.add(shakingKeyframe, forKey: "shaking")
      }
    )
    
    // 다수 애니메이션 (animateKeyframes): https://ios-development.tistory.com/815
    let multiKeyframeAnimationAction = UIAction(
      title: "다수 애니메이션 (animateKeyframes)",
      handler: { _ in
        UIView.animateKeyframes(
          withDuration: 3,
          delay: 0,
          animations: {
            UIView.addKeyframe(
              withRelativeStartTime: 0 / 4,
              relativeDuration: 1 / 4,
              animations: { self.animationTargetView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5) }
            )
            
            UIView.addKeyframe(
              withRelativeStartTime: 1 / 4,
              relativeDuration: 1 / 4,
              animations: { self.animationTargetView.transform = .identity }
            )
            
            UIView.addKeyframe(
              withRelativeStartTime: 2 / 4,
              relativeDuration: 1 / 4,
              animations: { self.animationTargetView.alpha = 0 }
            )
            
            UIView.addKeyframe(
              withRelativeStartTime: 3 / 4,
              relativeDuration: 1 / 4,
              animations: { self.animationTargetView.alpha = 1 }
            )
          },
          completion: nil
        )
      }
    )
    
    self.pullDownButton.menu = UIMenu(
      title: "애니메이션 옵션",
      image: nil,
      identifier: nil,
      options: .displayInline,
      children: [
        originAnimationAction,
        autolayoutAnimationAction,
        singleKeyframeAnimationAction,
        singleKeyframeAnimationSecondAction,
        multiKeyframeAnimationAction
      ]
    )
  }
}
