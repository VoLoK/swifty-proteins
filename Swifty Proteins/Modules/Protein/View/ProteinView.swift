// 
//  ProteinView.swift
//  Swifty Proteins
//
//  Created by Clothor- on 12/26/21.
//

import UIKit
import SceneKit

class ProteinView: UIViewController {
    // MARK: - Properties
    var presenter: ProteinViewOutput!
    
    private lazy var scnView: SCNView = {
        let scnView = SCNView()
        scnView.translatesAutoresizingMaskIntoConstraints = false
        return scnView
    }()

    // MARK: - Init
    convenience init(presenter: ProteinViewOutput) {
        self.init()
        self.presenter = presenter
    }

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }

    private func setupUI() {
        addSubviews()
        setupConstraints()
    }

    private func addSubviews() {
        view.addSubview(scnView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scnView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scnView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scnView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scnView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
}

// MARK: - View Input (Presenter -> View)
extension ProteinView: ProteinViewInput {
    func showMolecule(_ molecule: Molecule) {
        let scene = SCNScene()
        // set the scene to the view
        scnView.scene = scene
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        // configure the view
        scnView.autoenablesDefaultLighting = true
        scene.background.contents = UIColor(red: 60/255, green: 75/255, blue: 90/255, alpha: 1)
        // add molecule on the screen
        makeView(molecule)
    }
    
    
    private func makeView(_ molecule: Molecule) {
        guard let scene = scnView.scene else { return }
        for atom in molecule.atoms {
            let newAtom = createAtomNode(atom: atom)
            scene.rootNode.addChildNode(newAtom)
            for connect in atom.connects {
                guard let contact = molecule.atoms.first(where: { $0.id == connect }) else { continue }
                let cylindr = createCylinderNode(firstAtom: atom, secondAtom: contact)
                scene.rootNode.addChildNode(cylindr)
            }
        }
    }
    
    private func createAtomNode(atom: Atom) -> SCNNode {
        let atomSphere = SCNSphere(radius: 0.2)
        let atomNode = SCNNode(geometry: atomSphere)
        atomNode.position = atom.vector
        return atomNode
    }
    
    private func createCylinderNode(firstAtom: Atom, secondAtom: Atom) -> SCNNode {
        let height = GLKVector3Distance(SCNVector3ToGLKVector3(firstAtom.vector), SCNVector3ToGLKVector3(secondAtom.vector))
        let cylindre = SCNCylinder(radius: 0.10, height: CGFloat(height))
        let cylinderNode = SCNNode(geometry: cylindre)
        cylinderNode.position = SCNVector3(
            (firstAtom.vector.x + secondAtom.vector.x) / 2,
            (firstAtom.vector.y + secondAtom.vector.y) / 2,
            (firstAtom.vector.z + secondAtom.vector.z) / 2
        )
        cylinderNode.eulerAngles = SCNVector3Make(
            Float(Double.pi/2),
            acos((secondAtom.vector.z - firstAtom.vector.z) / height),
            atan2((secondAtom.vector.y - firstAtom.vector.y), (secondAtom.vector.x - firstAtom.vector.x))
        )
        
        return cylinderNode
    }
}
