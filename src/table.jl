# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

struct Table{T,C}
  rows::T
  crs::C
end

Tables.istable(::Type{<:Table}) = true
Tables.rowaccess(::Type{<:Table}) = true
Tables.rows(table::Table) = table.rows

GI.isfeaturecollection(::Type{<:Table}) = true
GI.trait(::Table) = GI.FeatureCollectionTrait()
GI.nfeature(::GI.FeatureCollectionTrait, table::Table) = length(table.rows)
GI.getfeature(::GI.FeatureCollectionTrait, table::Table, i) = table.rows[i]
GI.geometrycolumns(::Table) = (:geom,)
GI.crs(table::Table) = table.crs
