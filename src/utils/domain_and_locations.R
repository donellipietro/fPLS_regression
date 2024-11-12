generate_domain <- function(name_mesh = "unit_square", n_nodes = 1600) {
  switch(name_mesh,
    unit_square = {
      ## domain
      domain <- fdaPDE2::Mesh(unit_square(n_nodes))
      ## boundary
      domain_boundary <- extent(0, 1, 0, 1)
      domain_boundary <- as(domain_boundary, "SpatialPolygons")
      ## loadings generator
      loadings_true_generator <- cube_eigenfunction
      ## mesh fdaPDE1
      mesh <- fdaPDE::create.mesh.2D(domain$nodes)
    },
    c_shaped = {
      ## domain
      domain_data <- import_mesh_data("data/mesh/c_shaped/")
      domain <- fdaPDE2::Mesh(domain_data)
      ## boundary
      boundary_nodes <- data.frame(domain_data$nodes[as.logical(domain_data$boundary), ])
      points_sp <- SpatialPoints(boundary_nodes)
      domain_boundary <- SpatialPolygons(list(Polygons(list(Polygon(points_sp)), ID = 1)))
      ## loadings generator
      loadings_true_generator <- c_shape_domain_loadings
      ## mesh fdaPDE1
      mesh <- fdaPDE::create.mesh.2D(domain_data$nodes, segments = domain_data$edges, triangles = domain_data$elements)
    },
    {
      stop("The selected domain is not available.")
    }
  )
  return(list(
    domain = domain,
    domain_boundary = domain_boundary,
    loadings_true_generator = loadings_true_generator,
    mesh = mesh
  ))
}

generate_locations <- function(generated_domain = generate_domain(), locs_eq_nodes = FALSE) {
  if (locs_eq_nodes) {
    locations <- generated_domain$domain$nodes
    cat("\nLocations set to be equal to the nodes of the mesh!\n")
  } else {
    set.seed(-1)
    points <- spsample(generated_domain$domain_boundary, n_locs, type = "stratified")
    locations <- points@coords
    cat("\nCustom locations initialized!\n")
  }
  return(locations)
}
