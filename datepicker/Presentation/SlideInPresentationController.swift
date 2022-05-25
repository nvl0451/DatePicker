

//Custom Presentation Controller for the Get Date Sheets


import UIKit

class SlideInPresentationController: UIPresentationController {
  
  private var dimmingView: UIView!
  
  private var direction: PresentationDirection
  
  init(presentedViewController: UIViewController,
       presenting presentingViewController: UIViewController?,
       direction: PresentationDirection) {
    self.direction = direction
    
    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    
    setupDimmingView()
  }
    
  override func presentationTransitionWillBegin() {
    guard let dimmingView = dimmingView else {
      return
    }
    
    containerView?.insertSubview(dimmingView, at: 0)
    
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView])
    )
    NSLayoutConstraint.activate(
      NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView])
    )
    
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 1.0
      return
    }
    
    coordinator.animate(alongsideTransition: { _ in
      self.dimmingView.alpha = 1.0
    })
  }
  
  override func dismissalTransitionWillBegin() {
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 0.0
      return
    }
    
    coordinator.animate(alongsideTransition: { _ in
      self.dimmingView.alpha = 0.0
    })
  }
  
  override func containerViewDidLayoutSubviews() {
    presentedView?.frame = frameOfPresentedViewInContainerView
  }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        print("test test")
        containerView?.setNeedsLayout()
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
          self.containerView?.layoutIfNeeded()
        }, completion: nil)
    }
  
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
      switch direction {
      case .left, .right:
        return CGSize(width: parentSize.width*(2.0/3.0), height: parentSize.height)
      case .top, .bottom:
          return CGSize(width: parentSize.width, height: container.preferredContentSize.height)
      }
    }
    
  /*override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
      container.preferredContentSize.height
    switch direction {
    case .left, .right:
      return CGSize(width: parentSize.width*(2.0/3.0), height: parentSize.height)
    case .top, .bottom:
      return CGSize(width: parentSize.width, height: parentSize.height*(2.0/3.0))
    }
  }*/
  
  override var frameOfPresentedViewInContainerView: CGRect {
    var frame: CGRect = .zero
    frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
    
    switch direction {
    case .bottom:
        frame.origin.y = containerView!.frame.height - presentedViewController.preferredContentSize.height
    case .right:
      frame.origin.x = containerView!.frame.width*(1.0/3.0)
    default:
      frame.origin = .zero
    }
    
    return frame
  }

}

private extension SlideInPresentationController {
  func setupDimmingView() {
    dimmingView = UIView()
    dimmingView.translatesAutoresizingMaskIntoConstraints = false
    dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
    dimmingView.alpha = 0.0
    
    let recognizer = UITapGestureRecognizer(
      target: self, action: #selector(handleTap(recognizer:)))
    dimmingView.addGestureRecognizer(recognizer)
  }
  
  @objc func handleTap(recognizer: UITapGestureRecognizer) {
    presentingViewController.dismiss(animated: true)
  }
}
