//
//  ViewController.swift
//  inchurchmovie
//
//  Created by João Flavio Cardoso de Freitas Souza on 02/06/25.
//

import UIKit
import Kingfisher
import Combine

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var viewModel: MovieViewModel!
    private var isSearching: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    private var loadingContainerView: UIView!
    private var activityIndicator: UIActivityIndicatorView!
    private var loadingLabel: UILabel!
    var cancellables = Set<AnyCancellable>()
    var isCurrentlyLoading: Bool = false
    
    var searchController: UISearchController!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        viewModel = MovieViewModel()
        self.setupLoadingView()
        self.viewStatusBinding()
        self.presentLoadingStatus()
        self.setupNavigationBarButton()
        setupSearchController()
    }
    
    func setupNavigationBarButton() {
            // Crie um Bar Button Item com o ícone de lupa do sistema
            let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
            
            // Ou, se for uma imagem personalizada:
            // let customImage = UIImage(named: "lupa_icon") // Substitua "lupa_icon" pelo nome da sua imagem no Assets
            // let searchButton = UIBarButtonItem(image: customImage, style: .plain, target: self, action: #selector(searchButtonTapped))

            // Adicione o botão ao lado direito da barra de navegação
            navigationItem.rightBarButtonItem = searchButton
        }
    
    func setupSearchController() {
            // self se torna o controlador de resultados (aqui a busca filtra a própria lista de filmes)
            searchController = UISearchController(searchResultsController: nil)
            
            // O searchController será o delegado dos resultados da busca
            searchController.searchResultsUpdater = self
            
            // O searchController será o delegado da UI do controlador de busca
            searchController.delegate = self

            // Configurações visuais da barra de busca
            searchController.obscuresBackgroundDuringPresentation = false // Não escurece o fundo
            searchController.searchBar.placeholder = "Buscar filmes..."
            searchController.searchBar.delegate = self // Define o delegado da searchBar
            searchController.searchBar.searchTextField.isHidden = true

            // Se você quiser que a barra de busca permaneça visível na barra de navegação
            navigationItem.searchController = searchController
            
            // Se você quiser que a barra de busca esteja presente por padrão e possa ser clicada
            // Para o seu caso (ativar com a lupa), o acima é mais adequado.
            // navigationItem.hidesSearchBarWhenScrolling = false // Deixa a barra de busca visível ao rolar
        }


        @objc func searchButtonTapped() {
            print("Botão de busca (lupa) pressionado!")
            searchController.isActive = true
            searchController.searchBar.searchTextField.isHidden = false
            // Adicione aqui a lógica que você quer que aconteça quando o botão for clicado,
            // como mostrar uma barra de busca, navegar para uma tela de busca, etc.
        }
    
    private func setupLoadingView() {
            // 1. Create the container view
            loadingContainerView = UIView()
            loadingContainerView.translatesAutoresizingMaskIntoConstraints = false
            loadingContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.7) // Semi-transparent background
            loadingContainerView.layer.cornerRadius = 10
            self.view.addSubview(loadingContainerView)

            // 2. Create the activity indicator
            activityIndicator = UIActivityIndicatorView(style: .large) // Or .medium
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.color = .white // Make it visible on dark background
            activityIndicator.hidesWhenStopped = true
            loadingContainerView.addSubview(activityIndicator)

            // 3. Create the label
            loadingLabel = UILabel()
            loadingLabel.translatesAutoresizingMaskIntoConstraints = false
            loadingLabel.text = "Loading Movies..."
            loadingLabel.textColor = .white
            loadingLabel.textAlignment = .center
            loadingContainerView.addSubview(loadingLabel)

            // 4. Set constraints for the loadingContainerView
            NSLayoutConstraint.activate([
                loadingContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                loadingContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                loadingContainerView.widthAnchor.constraint(equalToConstant: 150), // Fixed width
                loadingContainerView.heightAnchor.constraint(equalToConstant: 150) // Fixed height
            ])

            // 5. Set constraints for the activityIndicator
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor),
                activityIndicator.topAnchor.constraint(equalTo: loadingContainerView.topAnchor, constant: 40)
            ])

            // 6. Set constraints for the loadingLabel
            NSLayoutConstraint.activate([
                loadingLabel.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor),
                loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10),
                loadingLabel.leadingAnchor.constraint(equalTo: loadingContainerView.leadingAnchor, constant: 10),
                loadingLabel.trailingAnchor.constraint(equalTo: loadingContainerView.trailingAnchor, constant: -10)
            ])
            
            loadingContainerView.isHidden = true
        }
}

extension ViewController: UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UIScrollViewDelegate {
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
    }
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return isSearching ? viewModel.searchMovies.count : viewModel.movies.count
     }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MovieCollectionViewCell
             let movie = isSearching ? viewModel.searchMovies[indexPath.row] : viewModel.movies[indexPath.row]
             cell.configure(with: movie)
             return cell
     }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.movies.count - 1 {
                   Task {
                       await viewModel.fetchMovies()
                   }
               }
    }

     // MARK: UICollectionViewDelegate
     
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         print("Você selecionou a célula \(indexPath.row)")
     }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        print(textField.text ?? "")
    }
}

extension ViewController {
    func viewStatusBinding() {
            viewModel.$status
            .sink { [weak self] status in
                guard let self else { return }
                DispatchQueue.main.async {
                           self.resetViewStatus()
                           switch status {
                           case .loading, .none:
                               self.presentLoadingStatus()
                           case .loaded:
                               self.presentLoadedStatus()
                           default:
                               break
                           }
                       }
            }.store(in: &cancellables)
        }

        private func resetViewStatus() {
            collectionView.isHidden = false
            loadingContainerView.isHidden = true
            activityIndicator.stopAnimating()
        }

        private func presentLoadingStatus() {
            collectionView.isHidden = false
            loadingContainerView.isHidden = false
            activityIndicator.startAnimating()
        }
    
    private func presentLoadedStatus() {
        loadingContainerView.isHidden = true
        activityIndicator.stopAnimating()
            
        let currentItemCount = self.collectionView.numberOfItems(inSection: 0)
        let newItemsCount = viewModel.movies.count
        
        guard newItemsCount > currentItemCount else {
            self.collectionView.reloadData()
            return
        }
        
        var indexPaths = [] as [IndexPath]
        for i in currentItemCount..<newItemsCount {
            indexPaths.append(IndexPath(item: i, section: 0))
        }
        self.collectionView.performBatchUpdates({self.collectionView.insertItems(at: indexPaths)})
       
    }

}

// ViewController.swift (continuação)

// --- NOVO: Extensão para os protocolos do Search Controller ---
extension ViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {

    // MARK: - UISearchResultsUpdating
    // Chamado quando o texto da busca muda
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        if searchText.isEmpty {
            noSearchLayout() // Volta para layout normal
        } else {
            searchLayout()   // Vai para layout de grid
        }
        
        collectionView.reloadData()
        
    }
    // MARK: - UISearchBarDelegate
    // Chamado quando o botão de busca virtual do teclado é tocado
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        print("Botão de busca clicado para: \(searchText)")
        // Geralmente, a mesma lógica de updateSearchResults(for:) ou para uma busca final
        // self.viewModel.performFinalSearch(query: searchText)
    }

    // Chamado quando o botão "Cancel" é tocado
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Busca cancelada")
        searchController.searchBar.searchTextField.isHidden = true
        // Limpar resultados da busca, se houver
        // self.viewModel.clearSearch()
        // self.collectionView.reloadData()
    }
    
    // MARK: - UISearchControllerDelegate (Opcional, para eventos da UI do SearchController)
    // Chamado quando o search controller está prestes a ser apresentado
    func willPresentSearchController(_ searchController: UISearchController) {
        print("Search Controller vai ser apresentado")
        // Aqui você pode ajustar sua UI, por exemplo, esconder outros elementos da navigation bar
    }
    
    // Chamado quando o search controller foi apresentado
    func didPresentSearchController(_ searchController: UISearchController) {
        print("Search Controller foi apresentado")
        // Foco automático na search bar
        DispatchQueue.main.async {
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    // Chamado quando o search controller está prestes a ser dispensado
    func willDismissSearchController(_ searchController: UISearchController) {
        print("Search Controller vai ser dispensado")
    }
    
    // Chamado quando o search controller foi dispensado
    func didDismissSearchController(_ searchController: UISearchController) {
        print("Search Controller foi dispensado")
        // Restaurar sua UI para o estado normal após o cancelamento da busca
    }
}

extension ViewController {
    func searchLayout() {
            let layout = UICollectionViewFlowLayout()

            let padding: CGFloat = 10
            let numberOfItemsPerRow: CGFloat = 2 // Dois filmes por linha
            let spacing: CGFloat = 5 // Espaçamento entre os itens

            let availableWidth = collectionView.bounds.width - (padding * 2) - (spacing * (numberOfItemsPerRow - 1))
            let itemWidth = availableWidth / numberOfItemsPerRow

            layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.5) // Ajuste a altura conforme necessário
            layout.minimumInteritemSpacing = spacing
            layout.minimumLineSpacing = spacing
            layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)

            // Aplica o novo layout com animação para uma transição suave
            collectionView.setCollectionViewLayout(layout, animated: true)
        }

        func noSearchLayout() {
            let layout = UICollectionViewFlowLayout()
            let padding: CGFloat = 10

            let itemWidth = collectionView.bounds.width - (padding * 2)
            layout.itemSize = CGSize(width: itemWidth, height: 120) // Altura para um item de lista
            layout.minimumLineSpacing = 1 // Espaçamento mínimo entre as linhas

            collectionView.setCollectionViewLayout(layout, animated: true)
        }
}
