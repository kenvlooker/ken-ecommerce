view: inventory_items {
  label: "Items in Inventory"
  sql_table_name: inventory_items ;;
  dimension: id {
    primary_key: yes
  type: number
  sql: ${TABLE}.id ;;
}

dimension: cost {
  type: number
  value_format_name: usd
  sql: ${TABLE}.cost ;;
}

dimension_group: created {
  type: time
  timeframes: [time, date, week, month, raw]
  sql: ${TABLE}.created_at ;;
}

dimension: product_id {
  type: number
  hidden: yes
  sql: ${TABLE}.product_id ;;
}

dimension_group: sold {
  type: time
  timeframes: [time, date, week, month, raw]
  sql: ${TABLE}.sold_at ;;
}

dimension: is_sold {
  type: yesno
  sql: ${sold_raw} is not null ;;
}

dimension: days_in_inventory {
  description: "days between created and sold date"
  type: number
  sql: DATEDIFF('day', ${created_raw}, coalesce(${sold_raw},CURRENT_DATE)) ;;
}

dimension: days_in_inventory_tier {
  type: tier
  sql: ${days_in_inventory} ;;
  style: integer
  tiers: [0, 5, 10, 20, 40, 80, 160, 360]
}

## THESE MEASURES ARE FOR CREATING A BOXPLOT ##

dimension: gross_margin {
  type: number
  value_format_name: usd
  sql: ${order_items.sale_price} - ${cost} ;;
}

measure: boxplot_min_test {
  type: min
  sql: ${gross_margin}  ;;
  value_format_name: decimal_2
}

measure: boxplot_25th_test {
  type: percentile
  percentile: 25
  sql: ${gross_margin} ;;
}

measure: boxplot_median_test {
  type: median
  sql: ${gross_margin} ;;
  value_format_name: decimal_2
}

measure: boxplot_75th_test {
  type: percentile
  percentile: 75
  sql: ${gross_margin} ;;
}

measure: boxplot_max_test {
  type: max
  sql: ${gross_margin}  ;;
  value_format_name: decimal_2
}


## THESE MEASURES ARE ALSO FOR CREATING A BOXPLOT

# measure: lifetime_min {
#   label: "Min"
#   type: min
#   sql: ${user_order_facts.lifetime_orders}  ;;
#   value_format_name: decimal_0
# }

# measure: lifetime_25th {
#   label: "25th Percentile"
#   type: percentile
#   percentile: 25
#   sql: ${user_order_facts.lifetime_orders}  ;;
# }

# measure: lifetime_median {
#   label: "Median"
#   type: median
#   sql: ${user_order_facts.lifetime_orders}  ;;
#   value_format_name: decimal_0
# }

# measure: lifetime_75th {
#   label: "75th Percentile"
#   type: percentile
#   percentile: 75
#   sql: ${user_order_facts.lifetime_orders}  ;;
# }

# measure: lifetime_max {
#   label: "Max"
#   type: max
#   sql: ${user_order_facts.lifetime_orders}  ;;
#   value_format_name: decimal_0
# }

############ END BOXPLOT TESTING ############

dimension: days_since_arrival {
  description: "days since created - useful when filtering on sold yesno for items still in inventory"
  type: number
  sql: DATEDIFF('day', ${created_date}, GETDATE()) ;;
}

dimension: days_since_arrival_tier {
  type: tier
  sql: ${days_since_arrival} ;;
  style: integer
  tiers: [0, 5, 10, 20, 40, 80, 160, 360]
}

dimension: product_distribution_center_id {
  hidden: yes
  sql: ${TABLE}.product_distribution_center_id ;;
}

measure: sold_count {
  type: count
  drill_fields: [detail*]
  filters:  {
    field: is_sold
    value: "Yes"
  }

}

measure: sold_percent {
  type: number
  value_format_name: percent_2
  sql: 1.0 * ${sold_count}/NULLIF(${count},0) ;;
}

measure: total_cost {
  type: sum
  value_format_name: usd
  sql: ${cost} ;;
}

measure: average_cost {
  type: average
  value_format_name: usd
  sql: ${cost} ;;
}

measure: count {
  type: count
  drill_fields: [detail*]
}

measure: number_on_hand {
  type: number
  sql: ${count} - ${sold_count} ;;
  drill_fields: [detail*]
}

set: detail {
  fields: [id, products.item_name, products.category, products.brand, products.department, cost, created_time, sold_time]
}

}
