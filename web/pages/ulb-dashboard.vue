<template>
  <div class="min-h-screen py-16 bg-gradient-to-b from-background to-waste2way-teal/5">
    <div class="container px-4 mx-auto">
      <div class="mb-8 space-y-2">
        <h1 class="text-3xl font-bold md:text-4xl">ULB Dashboard</h1>
        <p class="text-muted-foreground">
          Monitor waste hotspots and manage cleanup operations
        </p>
      </div>

      <div class="grid grid-cols-1 gap-6 mb-8 md:grid-cols-3">
        <StatsCard
          title="Critical Hotspots"
          :value="criticalCount.toString()"
          :change="criticalChange"
          :positive="false"
        >
          <template #icon>
            <AlertTriangle class="w-4 h-4 text-waste2way-coral" />
          </template>
        </StatsCard>

        <StatsCard
          title="Active Cleanup Tasks"
          :value="activeTasksCount.toString()"
        >
          <template #icon>
            <ClipboardCheck class="w-4 h-4 text-waste2way-teal" />
          </template>
        </StatsCard>

        <StatsCard
          title="Available Trucks"
          :value="availableTrucksCount.toString()"
        >
          <template #icon>
            <Truck class="w-4 h-4 text-waste2way-blue" />
          </template>
        </StatsCard>
      </div>

      <!-- Tabs -->
      <div class="p-1 mb-6 glass-card dark:glass-card-dark rounded-xl">
        <div class="flex border-b border-border">
          <button
            v-for="tab in tabs"
            :key="tab.id"
            @click="activeTab = tab.id"
            class="px-4 py-3 text-sm font-medium transition-colors rounded-t-lg"
            :class="
              activeTab === tab.id
                ? 'bg-white dark:bg-waste2way-dark/50 border-b-2 border-waste2way-teal'
                : 'hover:bg-white/10'
            "
          >
            <component :is="tab.icon" class="inline-block w-4 h-4 mr-2" />
            {{ tab.label }}
          </button>
        </div>

        <div class="p-6">
          <!-- Hotspots Tab -->
          <div v-if="activeTab === 'hotspots'" class="space-y-6">
            <div class="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
              <h2 class="text-xl font-bold">Critical Waste Hotspots</h2>
              <button
                @click="monitorHotspots"
                class="flex items-center px-4 py-2 space-x-2 text-sm font-medium rounded-lg bg-waste2way-teal text-white"
                :disabled="isMonitoring"
              >
                <RefreshCw v-if="isMonitoring" class="w-4 h-4 mr-2 animate-spin" />
                <Radar v-else class="w-4 h-4 mr-2" />
                {{ isMonitoring ? 'Monitoring...' : 'Monitor Hotspots' }}
              </button>
            </div>

            <div v-if="isLoading" class="flex items-center justify-center py-12">
              <div class="w-12 h-12 border-b-2 border-waste2way-teal rounded-full animate-spin"></div>
            </div>

            <div v-else-if="!criticalHotspots.length" class="p-12 text-center text-muted-foreground">
              <Trash2 class="w-12 h-12 mx-auto mb-4 text-muted-foreground/50" />
              <p class="mb-2 text-lg font-medium">No critical hotspots found</p>
              <p>All areas are currently below critical threshold</p>
            </div>

            <div v-else>
              <div class="overflow-hidden border rounded-lg shadow-sm">
                <table class="w-full text-sm text-left">
                  <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-waste2way-dark/50 dark:text-gray-300">
                    <tr>
                      <th scope="col" class="px-6 py-3">Location</th>
                      <th scope="col" class="px-6 py-3">Severity</th>
                      <th scope="col" class="px-6 py-3">Reports</th>
                      <th scope="col" class="px-6 py-3">Last Reported</th>
                      <th scope="col" class="px-6 py-3">Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="hotspot in criticalHotspots" :key="`${hotspot.latGroup}-${hotspot.lngGroup}`" class="bg-white border-b dark:bg-waste2way-dark/20 dark:border-gray-700">
                      <td class="px-6 py-4">
                        {{ getAddressFromCoords(hotspot.latGroup, hotspot.lngGroup) }}
                      </td>
                      <td class="px-6 py-4">
                        <div class="flex items-center">
                          <div 
                            class="w-3 h-3 mr-2 rounded-full" 
                            :class="getSeverityDotClass(hotspot.avgSeverity)">
                          </div>
                          <span>{{ getSeverityText(hotspot.avgSeverity) }} ({{ hotspot.avgSeverity.toFixed(1) }})</span>
                        </div>
                      </td>
                      <td class="px-6 py-4">{{ hotspot.reportCount }}</td>
                      <td class="px-6 py-4">{{ formatDate(hotspot.reports[0]?.timestamp) }}</td>
                      <td class="px-6 py-4">
                        <button
                          @click="assignCleanupTask(hotspot)"
                          class="px-3 py-1 text-xs font-medium rounded-full text-white bg-waste2way-teal hover:bg-waste2way-teal/90"
                          :disabled="!availableTrucksCount"
                        >
                          Assign Cleanup
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Tasks Tab -->
          <div v-if="activeTab === 'tasks'" class="space-y-6">
            <div class="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
              <h2 class="text-xl font-bold">Cleanup Tasks</h2>
              <div class="flex space-x-2">
                <select 
                  v-model="taskFilter" 
                  class="px-3 py-2 text-sm border rounded-lg border-input bg-background"
                >
                  <option value="all">All Tasks</option>
                  <option value="ASSIGNED">Assigned</option>
                  <option value="IN_PROGRESS">In Progress</option>
                  <option value="COMPLETED">Completed</option>
                </select>
                <button
                  @click="fetchCleanupTasks"
                  class="flex items-center p-2 text-sm font-medium rounded-lg bg-waste2way-teal/10 text-waste2way-teal"
                >
                  <RefreshCw class="w-4 h-4" />
                </button>
              </div>
            </div>

            <div v-if="tasksLoading" class="flex items-center justify-center py-12">
              <div class="w-12 h-12 border-b-2 border-waste2way-teal rounded-full animate-spin"></div>
            </div>

            <div v-else-if="!cleanupTasks.length" class="p-12 text-center text-muted-foreground">
              <ClipboardList class="w-12 h-12 mx-auto mb-4 text-muted-foreground/50" />
              <p class="mb-2 text-lg font-medium">No cleanup tasks found</p>
              <p>No tasks match the current filter</p>
            </div>

            <div v-else>
              <div class="overflow-hidden border rounded-lg shadow-sm">
                <table class="w-full text-sm text-left">
                  <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-waste2way-dark/50 dark:text-gray-300">
                    <tr>
                      <th scope="col" class="px-6 py-3">Task ID</th>
                      <th scope="col" class="px-6 py-3">Location</th>
                      <th scope="col" class="px-6 py-3">Truck</th>
                      <th scope="col" class="px-6 py-3">Status</th>
                      <th scope="col" class="px-6 py-3">Created At</th>
                      <th scope="col" class="px-6 py-3">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="task in cleanupTasks" :key="task.id" class="bg-white border-b dark:bg-waste2way-dark/20 dark:border-gray-700">
                      <td class="px-6 py-4">#{{ task.id }}</td>
                      <td class="px-6 py-4">
                        {{ getAddressFromCoords(task.latitude, task.longitude) }}
                      </td>
                      <td class="px-6 py-4">{{ task.truck.truckNumber }}</td>
                      <td class="px-6 py-4">
                        <span 
                          class="px-2.5 py-0.5 text-xs font-medium rounded-full" 
                          :class="getStatusClass(task.status)"
                        >
                          {{ task.status }}
                        </span>
                      </td>
                      <td class="px-6 py-4">{{ formatDate(task.createdAt) }}</td>
                      <td class="px-6 py-4">
                        <div class="flex space-x-2">
                          <button
                            v-if="task.status === 'ASSIGNED'"
                            @click="updateTaskStatus(task.id, 'IN_PROGRESS')"
                            class="px-3 py-1 text-xs font-medium rounded-full text-white bg-blue-500 hover:bg-blue-600"
                          >
                            Start
                          </button>
                          <button
                            v-if="task.status === 'IN_PROGRESS'"
                            @click="openCompleteTaskModal(task)"
                            class="px-3 py-1 text-xs font-medium rounded-full text-white bg-green-500 hover:bg-green-600"
                          >
                            Complete
                          </button>
                          <button
                            v-if="task.status !== 'COMPLETED'"
                            @click="viewTaskDetails(task)"
                            class="px-3 py-1 text-xs font-medium rounded-full text-waste2way-teal bg-waste2way-teal/10 hover:bg-waste2way-teal/20"
                          >
                            View
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Trucks Tab -->
          <div v-if="activeTab === 'trucks'" class="space-y-6">
            <div class="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
              <h2 class="text-xl font-bold">Fleet Management</h2>
              <button
                @click="openAddTruckModal"
                class="flex items-center px-4 py-2 space-x-2 text-sm font-medium rounded-lg bg-waste2way-teal text-white"
              >
                <PlusCircle class="w-4 h-4 mr-2" />
                Add Truck
              </button>
            </div>

            <div v-if="trucksLoading" class="flex items-center justify-center py-12">
              <div class="w-12 h-12 border-b-2 border-waste2way-teal rounded-full animate-spin"></div>
            </div>

            <div v-else-if="!trucks.length" class="p-12 text-center text-muted-foreground">
              <Truck class="w-12 h-12 mx-auto mb-4 text-muted-foreground/50" />
              <p class="mb-2 text-lg font-medium">No trucks available</p>
              <p>Add trucks to your fleet to manage cleanup operations</p>
            </div>

            <div v-else>
              <div class="overflow-hidden border rounded-lg shadow-sm">
                <table class="w-full text-sm text-left">
                  <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-waste2way-dark/50 dark:text-gray-300">
                    <tr>
                      <th scope="col" class="px-6 py-3">Truck Number</th>
                      <th scope="col" class="px-6 py-3">Status</th>
                      <th scope="col" class="px-6 py-3">Current Task</th>
                      <th scope="col" class="px-6 py-3">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="truck in trucks" :key="truck.id" class="bg-white border-b dark:bg-waste2way-dark/20 dark:border-gray-700">
                      <td class="px-6 py-4">{{ truck.truckNumber }}</td>
                      <td class="px-6 py-4">
                        <span 
                          class="px-2.5 py-0.5 text-xs font-medium rounded-full" 
                          :class="getTruckStatusClass(truck.status)"
                        >
                          {{ truck.status }}
                        </span>
                      </td>
                      <td class="px-6 py-4">
                        <span v-if="getTruckTask(truck.id)">
                          Task #{{ getTruckTask(truck.id) }}
                        </span>
                        <span v-else class="text-muted-foreground">No active task</span>
                      </td>
                      <td class="px-6 py-4">
                        <div class="flex space-x-2">
                          <button
                            v-if="truck.status === 'AVAILABLE'"
                            @click="setTruckMaintenance(truck.id)"
                            class="px-3 py-1 text-xs font-medium rounded-full text-amber-700 bg-amber-100 hover:bg-amber-200"
                          >
                            Set to Maintenance
                          </button>
                          <button
                            v-if="truck.status === 'MAINTENANCE'"
                            @click="setTruckAvailable(truck.id)"
                            class="px-3 py-1 text-xs font-medium rounded-full text-green-700 bg-green-100 hover:bg-green-200"
                          >
                            Set to Available
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Materials Tab -->
          <div v-if="activeTab === 'materials'" class="space-y-6">
            <h2 class="text-xl font-bold">Recycling Materials</h2>

            <div v-if="materialsLoading" class="flex items-center justify-center py-12">
              <div class="w-12 h-12 border-b-2 border-waste2way-teal rounded-full animate-spin"></div>
            </div>

            <div v-else>
              <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <div class="p-6 rounded-lg glass-card dark:glass-card-dark">
                  <h3 class="mb-4 text-lg font-medium">Material Distribution</h3>
                  <div class="h-64">
                    <canvas ref="materialChart"></canvas>
                  </div>
                </div>

                <div class="p-6 rounded-lg glass-card dark:glass-card-dark">
                  <h3 class="mb-4 text-lg font-medium">Recent Materials Collected</h3>
                  <div class="overflow-auto max-h-64">
                    <table class="w-full text-sm text-left">
                      <thead class="text-xs text-gray-700 sticky top-0 bg-white dark:bg-waste2way-dark/50 dark:text-gray-300">
                        <tr>
                          <th scope="col" class="px-4 py-2">Date</th>
                          <th scope="col" class="px-4 py-2">Plastic</th>
                          <th scope="col" class="px-4 py-2">Paper</th>
                          <th scope="col" class="px-4 py-2">Glass</th>
                          <th scope="col" class="px-4 py-2">Metal</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-for="material in recyclingMaterials" :key="material.id" class="border-b dark:border-gray-700">
                          <td class="px-4 py-2">{{ formatDate(material.createdAt) }}</td>
                          <td class="px-4 py-2">{{ material.plasticWeight }}kg</td>
                          <td class="px-4 py-2">{{ material.paperWeight }}kg</td>
                          <td class="px-4 py-2">{{ material.glassWeight }}kg</td>
                          <td class="px-4 py-2">{{ material.metalWeight }}kg</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>

              <div class="grid grid-cols-1 gap-6 mt-6 md:grid-cols-3">
                <div class="p-6 rounded-lg glass-card dark:glass-card-dark">
                  <h3 class="mb-2 text-sm font-medium text-muted-foreground">Total Plastic Collected</h3>
                  <p class="text-2xl font-bold">{{ getTotalMaterial('plastic') }}kg</p>
                  <div class="w-full h-2 mt-2 rounded-full bg-muted">
                    <div
                      class="h-2 rounded-full bg-waste2way-teal"
                      :style="{ width: `${getMaterialPercentage('plastic')}%` }"
                    ></div>
                  </div>
                </div>

                <div class="p-6 rounded-lg glass-card dark:glass-card-dark">
                  <h3 class="mb-2 text-sm font-medium text-muted-foreground">Material Destination Types</h3>
                  <div class="flex flex-wrap gap-2 mt-2">
                    <div 
                      v-for="(count, destination) in destinationCounts" 
                      :key="destination"
                      class="px-2 py-1 text-xs rounded-full bg-waste2way-teal/10 text-waste2way-teal"
                    >
                      {{ formatDestination(destination) }}: {{ count }}
                    </div>
                  </div>
                </div>

                <div class="p-6 rounded-lg glass-card dark:glass-card-dark">
                  <h3 class="mb-2 text-sm font-medium text-muted-foreground">Environmental Impact</h3>
                  <p class="text-lg font-medium">{{ calculateCO2Reduction() }}kg CO₂ saved</p>
                  <p class="text-sm text-muted-foreground">Based on recycled materials</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Add Truck Modal -->
    <Modal :show="showAddTruckModal" @close="showAddTruckModal = false">
      <div class="p-6">
        <h3 class="mb-4 text-lg font-medium">Add New Truck</h3>
        <div class="mb-4">
          <label class="block mb-2 text-sm font-medium">Truck Number</label>
          <input 
            v-model="newTruck.truckNumber"
            type="text" 
            class="w-full px-3 py-2 border rounded-lg"
            placeholder="Enter truck number or identifier"
          />
        </div>
        <div class="flex justify-end space-x-3">
          <button 
            @click="showAddTruckModal = false"
            class="px-4 py-2 text-sm font-medium border rounded-lg border-input bg-background hover:bg-accent hover:text-accent-foreground"
          >
            Cancel
          </button>
          <button 
            @click="addTruck"
            class="px-4 py-2 text-sm font-medium rounded-lg text-white bg-waste2way-teal hover:bg-waste2way-teal/90"
            :disabled="!newTruck.truckNumber"
          >
            Add Truck
          </button>
        </div>
      </div>
    </Modal>

    <!-- Complete Task Modal -->
    <Modal :show="showCompleteTaskModal" @close="showCompleteTaskModal = false">
      <div class="p-6">
        <h3 class="mb-4 text-lg font-medium">Complete Cleanup Task</h3>
        <p class="mb-4 text-sm text-muted-foreground">Record materials collected during this cleanup operation</p>
        
        <div class="grid grid-cols-2 gap-4 mb-4">
          <div>
            <label class="block mb-2 text-sm font-medium">Plastic Weight (kg)</label>
            <input 
              v-model="taskMaterialData.plasticWeight"
              type="number" 
              min="0"
              step="0.1"
              class="w-full px-3 py-2 border rounded-lg"
            />
          </div>
          <div>
            <label class="block mb-2 text-sm font-medium">Paper Weight (kg)</label>
            <input 
              v-model="taskMaterialData.paperWeight"
              type="number" 
              min="0"
              step="0.1"
              class="w-full px-3 py-2 border rounded-lg"
            />
          </div>
          <div>
            <label class="block mb-2 text-sm font-medium">Glass Weight (kg)</label>
            <input 
              v-model="taskMaterialData.glassWeight"
              type="number" 
              min="0"
              step="0.1"
              class="w-full px-3 py-2 border rounded-lg"
            />
          </div>
          <div>
            <label class="block mb-2 text-sm font-medium">Metal Weight (kg)</label>
            <input 
              v-model="taskMaterialData.metalWeight"
              type="number" 
              min="0"
              step="0.1"
              class="w-full px-3 py-2 border rounded-lg"
            />
          </div>
          <div>
            <label class="block mb-2 text-sm font-medium">Organic Weight (kg)</label>
            <input 
              v-model="taskMaterialData.organicWeight"
              type="number" 
              min="0"
              step="0.1"
              class="w-full px-3 py-2 border rounded-lg"
            />
          </div>
          <div>
            <label class="block mb-2 text-sm font-medium">Other Weight (kg)</label>
            <input 
              v-model="taskMaterialData.otherWeight"
              type="number" 
              min="0"
              step="0.1"
              class="w-full px-3 py-2 border rounded-lg"
            />
          </div>
        </div>

        <div class="mb-4">
          <label class="block mb-2 text-sm font-medium">Destination Type</label>
          <select 
            v-model="taskMaterialData.destinationType"
            class="w-full px-3 py-2 border rounded-lg"
          >
            <option value="RECYCLING_CENTER">Recycling Center</option>
            <option value="INFRASTRUCTURE">Infrastructure Projects</option>
            <option value="SCRAP_ARTISTS">Scrap Artists</option>
          </select>
        </div>
        
        <div class="flex justify-end space-x-3">
          <button 
            @click="showCompleteTaskModal = false"
            class="px-4 py-2 text-sm font-medium border rounded-lg border-input bg-background hover:bg-accent hover:text-accent-foreground"
          >
            Cancel
          </button>
          <button 
            @click="completeTask"
            class="px-4 py-2 text-sm font-medium rounded-lg text-white bg-green-500 hover:bg-green-600"
          >
            Complete Task
          </button>
        </div>
      </div>
    </Modal>

    <!-- Task Detail Modal -->
    <Modal :show="showTaskDetailModal" @close="showTaskDetailModal = false">
      <div class="p-6">
        <h3 class="mb-4 text-lg font-medium">Task Details</h3>
        <div v-if="selectedTask" class="space-y-4">
          <div class="p-4 rounded-lg bg-muted">
            <div class="grid grid-cols-2 gap-4">
              <div>
                <p class="text-sm text-muted-foreground">Task ID</p>
                <p class="font-medium">#{{ selectedTask.id }}</p>
              </div>
              <div>
                <p class="text-sm text-muted-foreground">Status</p>
                <p>
                  <span 
                    class="px-2.5 py-0.5 text-xs font-medium rounded-full" 
                    :class="getStatusClass(selectedTask.status)"
                  >
                    {{ selectedTask.status }}
                  </span>
                </p>
              </div>
              <div>
                <p class="text-sm text-muted-foreground">Location</p>
                <p class="font-medium">{{ getAddressFromCoords(selectedTask.latitude, selectedTask.longitude) }}</p>
              </div>
              <div>
                <p class="text-sm text-muted-foreground">Truck</p>
                <p class="font-medium">{{ selectedTask.truck.truckNumber }}</p>
              </div>
              <div>
                <p class="text-sm text-muted-foreground">Report Count</p>
                <p class="font-medium">{{ selectedTask.reportCount }}</p>
              </div>
              <div>
                <p class="text-sm text-muted-foreground">Average Severity</p>
                <p class="font-medium">{{ selectedTask.avgSeverity.toFixed(1) }}</p>
              </div>
              <div>
                <p class="text-sm text-muted-foreground">Created At</p>
                <p class="font-medium">{{ formatDate(selectedTask.createdAt) }}</p>
              </div>
            </div>
          </div>

          <div v-if="selectedTask.reportIds?.length">
            <h4 class="mb-2 text-sm font-medium">Related Reports</h4>
            <ul class="pl-5 space-y-1 list-disc">
              <li v-for="reportId in selectedTask.reportIds" :key="reportId" class="text-sm">
                Report #{{ reportId }}
              </li>
            </ul>
          </div>

          <div class="flex justify-end">
            <button 
              @click="showTaskDetailModal = false"
              class="px-4 py-2 text-sm font-medium border rounded-lg border-input bg-background hover:bg-accent hover:text-accent-foreground"
            >
              Close
            </button>
          </div>
        </div>
      </div>
    </Modal>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import { 
  AlertTriangle, ClipboardCheck, Truck, RefreshCw, Radar, Trash2, 
  ClipboardList, PlusCircle, Map, BarChart3
} from 'lucide-vue-next';
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);

const { get, post, put } = useApi();

// Tabs
const tabs = [
  { id: 'hotspots', label: 'Hotspots', icon: Map },
  { id: 'tasks', label: 'Cleanup Tasks', icon: ClipboardList },
  { id: 'trucks', label: 'Trucks', icon: Truck },
  { id: 'materials', label: 'Materials', icon: BarChart3 },
];
const activeTab = ref('hotspots');

// State
const isLoading = ref(false);
const tasksLoading = ref(false);
const trucksLoading = ref(false);
const materialsLoading = ref(false);
const isMonitoring = ref(false);
const criticalHotspots = ref([]);
const cleanupTasks = ref([]);
const trucks = ref([]);
const recyclingMaterials = ref([]);
const taskFilter = ref('all');
const criticalCount = ref(0);
const criticalChange = ref('8%');
const activeTasksCount = ref(0);
const availableTrucksCount = ref(0);

// Modal state
const showAddTruckModal = ref(false);
const showCompleteTaskModal = ref(false);
const showTaskDetailModal = ref(false);
const selectedTask = ref(null);
const newTruck = ref({ truckNumber: '' });
const taskMaterialData = ref({
  plasticWeight: 0,
  paperWeight: 0,
  glassWeight: 0,
  metalWeight: 0,
  organicWeight: 0,
  otherWeight: 0,
  destinationType: 'RECYCLING_CENTER'
});

// Chart refs
const materialChart = ref(null);
let chartInstance = null;

// Watch for tab changes to load data
watch(activeTab, (newTab) => {
  if (newTab === 'tasks') {
    fetchCleanupTasks();
  } else if (newTab === 'trucks') {
    fetchTrucks();
  } else if (newTab === 'materials') {
    fetchRecyclingMaterials();
  }
});

// Watch task filter changes
watch(taskFilter, () => {
  fetchCleanupTasks();
});

// Methods
async function monitorHotspots() {
  isMonitoring.value = true;
  isLoading.value = true;
  
  try {
    const { data } = await post('/cleanup/monitor');
    await fetchCriticalHotspots();
    console.log('Monitoring result:', data);
  } catch (error) {
    console.error('Error monitoring hotspots:', error);
  } finally {
    isMonitoring.value = false;
    isLoading.value = false;
  }
}

async function fetchCriticalHotspots() {
  isLoading.value = true;
  
  try {
    const { data } = await get('/trash/hotspots');
    // Filter for critical hotspots (those with reportCount >= 5)
    criticalHotspots.value = data.filter(hotspot => hotspot.reportCount >= 5);
    criticalCount.value = criticalHotspots.value.length;
  } catch (error) {
    console.error('Error fetching hotspots:', error);
  } finally {
    isLoading.value = false;
  }
}

async function fetchCleanupTasks() {
  tasksLoading.value = true;
  
  try {
    let endpoint = '/cleanup/tasks';
    if (taskFilter.value !== 'all') {
      endpoint += `?status=${taskFilter.value}`;
    }
    
    const { data } = await get(endpoint);
    cleanupTasks.value = data;
    activeTasksCount.value = data.filter(task => 
      task.status === 'ASSIGNED' || task.status === 'IN_PROGRESS'
    ).length;
  } catch (error) {
    console.error('Error fetching cleanup tasks:', error);
  } finally {
    tasksLoading.value = false;
  }
}

async function fetchTrucks() {
  trucksLoading.value = true;
  
  try {
    const { data } = await get('/trucks');
    trucks.value = data;
    availableTrucksCount.value = data.filter(truck => truck.status === 'AVAILABLE').length;
  } catch (error) {
    console.error('Error fetching trucks:', error);
  } finally {
    trucksLoading.value = false;
  }
}

async function fetchRecyclingMaterials() {
  materialsLoading.value = true;
  
  try {
    const { data } = await get('/materials');
    recyclingMaterials.value = data;
    renderMaterialChart();
  } catch (error) {
    console.error('Error fetching recycling materials:', error);
  } finally {
    materialsLoading.value = false;
  }
}

async function assignCleanupTask(hotspot) {
  try {
    await post('/cleanup/tasks', {
      latitude: hotspot.latGroup,
      longitude: hotspot.lngGroup,
      reportIds: hotspot.reports.map(r => r.id),
      reportCount: hotspot.reportCount,
      avgSeverity: hotspot.avgSeverity
    });
    
    // Refresh data
    await fetchCriticalHotspots();
    await fetchCleanupTasks();
    await fetchTrucks();
  } catch (error) {
    console.error('Error assigning cleanup task:', error);
  }
}

async function updateTaskStatus(taskId, status) {
  try {
    await put(`/cleanup/tasks/${taskId}`, { status });
    await fetchCleanupTasks();
  } catch (error) {
    console.error('Error updating task status:', error);
  }
}

function openCompleteTaskModal(task) {
  selectedTask.value = task;
  showCompleteTaskModal.value = true;
  
  // Reset material data
  taskMaterialData.value = {
    plasticWeight: 0,
    paperWeight: 0,
    glassWeight: 0,
    metalWeight: 0,
    organicWeight: 0,
    otherWeight: 0,
    destinationType: 'RECYCLING_CENTER'
  };
}

async function completeTask() {
  if (!selectedTask.value) return;
  
  try {
    await put(`/cleanup/tasks/${selectedTask.value.id}`, { 
      status: 'COMPLETED',
      materialData: taskMaterialData.value
    });
    
    showCompleteTaskModal.value = false;
    await fetchCleanupTasks();
    await fetchTrucks();
    
    if (activeTab.value === 'materials') {
      await fetchRecyclingMaterials();
    }
  } catch (error) {
    console.error('Error completing task:', error);
  }
}

function viewTaskDetails(task) {
  selectedTask.value = task;
  showTaskDetailModal.value = true;
}

function openAddTruckModal() {
  newTruck.value = { truckNumber: '' };
  showAddTruckModal.value = true;
}

async function addTruck() {
  if (!newTruck.value.truckNumber) return;
  
  try {
    await post('/trucks', newTruck.value);
    showAddTruckModal.value = false;
    await fetchTrucks();
  } catch (error) {
    console.error('Error adding truck:', error);
  }
}

async function setTruckMaintenance(truckId) {
  try {
    await put(`/trucks/${truckId}`, { status: 'MAINTENANCE' });
    await fetchTrucks();
  } catch (error) {
    console.error('Error setting truck to maintenance:', error);
  }
}

async function setTruckAvailable(truckId) {
  try {
    await put(`/trucks/${truckId}`, { status: 'AVAILABLE' });
    await fetchTrucks();
  } catch (error) {
    console.error('Error setting truck to available:', error);
  }
}

function renderMaterialChart() {
  if (chartInstance) {
    chartInstance.destroy();
  }
  
  if (!materialChart.value) return;
  
  const ctx = materialChart.value.getContext('2d');
  
  // Calculate totals
  const totalPlastic = getTotalMaterial('plastic');
  const totalPaper = getTotalMaterial('paper');
  const totalGlass = getTotalMaterial('glass');
  const totalMetal = getTotalMaterial('metal');
  const totalOrganic = getTotalMaterial('organic');
  const totalOther = getTotalMaterial('other');
  
  chartInstance = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: ['Plastic', 'Paper', 'Glass', 'Metal', 'Organic', 'Other'],
      datasets: [{
        data: [totalPlastic, totalPaper, totalGlass, totalMetal, totalOrganic, totalOther],
        backgroundColor: [
          '#2A9D8F', // waste2way-teal
          '#48CAE4', // waste2way-blue
          '#57CC99', // waste2way-green
          '#F4845F', // waste2way-coral
          '#023E8A', // waste2way-navy
          '#6// filepath: d:\Projects\Personal\waste-2-ways\web\pages\ulb-dashboard.vue
<template>
  <div class="min-h-screen py-16 bg-gradient-to-b from-background to-waste2way-teal/5">
    <div class="container px-4 mx-auto">
      <div class="mb-8 space-y-2">
        <h1 class="text-3xl font-bold md:text-4xl">ULB Dashboard</h1>
        <p class="text-muted-foreground">
          Monitor waste hotspots and manage cleanup operations
        </p>
      </div>

      <div class="grid grid-cols-1 gap-6 mb-8 md:grid-cols-3">
        <StatsCard
          title="Critical Hotspots"
          :value="criticalCount.toString()"
          :change="criticalChange"
          :positive="false"
        >
          <template #icon>
            <AlertTriangle class="w-4 h-4 text-waste2way-coral" />
          </template>
        </StatsCard>

        <StatsCard
          title="Active Cleanup Tasks"
          :value="activeTasksCount.toString()"
        >
          <template #icon>
            <ClipboardCheck class="w-4 h-4 text-waste2way-teal" />
          </template>
        </StatsCard>

        <StatsCard
          title="Available Trucks"
          :value="availableTrucksCount.toString()"
        >
          <template #icon>
            <Truck class="w-4 h-4 text-waste2way-blue" />
          </template>
        </StatsCard>
      </div>

      <!-- Tabs -->
      <div class="p-1 mb-6 glass-card dark:glass-card-dark rounded-xl">
        <div class="flex border-b border-border">
          <button
            v-for="tab in tabs"
            :key="tab.id"
            @click="activeTab = tab.id"
            class="px-4 py-3 text-sm font-medium transition-colors rounded-t-lg"
            :class="
              activeTab === tab.id
                ? 'bg-white dark:bg-waste2way-dark/50 border-b-2 border-waste2way-teal'
                : 'hover:bg-white/10'
            "
          >
            <component :is="tab.icon" class="inline-block w-4 h-4 mr-2" />
            {{ tab.label }}
          </button>
        </div>

        <div class="p-6">
          <!-- Hotspots Tab -->
          <div v-if="activeTab === 'hotspots'" class="space-y-6">
            <div class="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
              <h2 class="text-xl font-bold">Critical Waste Hotspots</h2>
              <button
                @click="monitorHotspots"
                class="flex items-center px-4 py-2 space-x-2 text-sm font-medium rounded-lg bg-waste2way-teal text-white"
                :disabled="isMonitoring"
              >
                <RefreshCw v-if="isMonitoring" class="w-4 h-4 mr-2 animate-spin" />
                <Radar v-else class="w-4 h-4 mr-2" />
                {{ isMonitoring ? 'Monitoring...' : 'Monitor Hotspots' }}
              </button>
            </div>

            <div v-if="isLoading" class="flex items-center justify-center py-12">
              <div class="w-12 h-12 border-b-2 border-waste2way-teal rounded-full animate-spin"></div>
            </div>

            <div v-else-if="!criticalHotspots.length" class="p-12 text-center text-muted-foreground">
              <Trash2 class="w-12 h-12 mx-auto mb-4 text-muted-foreground/50" />
              <p class="mb-2 text-lg font-medium">No critical hotspots found</p>
              <p>All areas are currently below critical threshold</p>
            </div>

            <div v-else>
              <div class="overflow-hidden border rounded-lg shadow-sm">
                <table class="w-full text-sm text-left">
                  <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-waste2way-dark/50 dark:text-gray-300">
                    <tr>
                      <th scope="col" class="px-6 py-3">Location</th>
                      <th scope="col" class="px-6 py-3">Severity</th>
                      <th scope="col" class="px-6 py-3">Reports</th>
                      <th scope="col" class="px-6 py-3">Last Reported</th>
                      <th scope="col" class="px-6 py-3">Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="hotspot in criticalHotspots" :key="`${hotspot.latGroup}-${hotspot.lngGroup}`" class="bg-white border-b dark:bg-waste2way-dark/20 dark:border-gray-700">
                      <td class="px-6 py-4">
                        {{ getAddressFromCoords(hotspot.latGroup, hotspot.lngGroup) }}
                      </td>
                      <td class="px-6 py-4">
                        <div class="flex items-center">
                          <div 
                            class="w-3 h-3 mr-2 rounded-full" 
                            :class="getSeverityDotClass(hotspot.avgSeverity)">
                          </div>
                          <span>{{ getSeverityText(hotspot.avgSeverity) }} ({{ hotspot.avgSeverity.toFixed(1) }})</span>
                        </div>
                      </td>
                      <td class="px-6 py-4">{{ hotspot.reportCount }}</td>
                      <td class="px-6 py-4">{{ formatDate(hotspot.reports[0]?.timestamp) }}</td>
                      <td class="px-6 py-4">
                        <button
                          @click="assignCleanupTask(hotspot)"
                          class="px-3 py-1 text-xs font-medium rounded-full text-white bg-waste2way-teal hover:bg-waste2way-teal/90"
                          :disabled="!availableTrucksCount"
                        >
                          Assign Cleanup
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Tasks Tab -->
          <div v-if="activeTab === 'tasks'" class="space-y-6">
            <div class="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
              <h2 class="text-xl font-bold">Cleanup Tasks</h2>
              <div class="flex space-x-2">
                <select 
                  v-model="taskFilter" 
                  class="px-3 py-2 text-sm border rounded-lg border-input bg-background"
                >
                  <option value="all">All Tasks</option>
                  <option value="ASSIGNED">Assigned</option>
                  <option value="IN_PROGRESS">In Progress</option>
                  <option value="COMPLETED">Completed</option>
                </select>
                <button
                  @click="fetchCleanupTasks"
                  class="flex items-center p-2 text-sm font-medium rounded-lg bg-waste2way-teal/10 text-waste2way-teal"
                >
                  <RefreshCw class="w-4 h-4" />
                </button>
              </div>
            </div>

            <div v-if="tasksLoading" class="flex items-center justify-center py-12">
              <div class="w-12 h-12 border-b-2 border-waste2way-teal rounded-full animate-spin"></div>
            </div>

            <div v-else-if="!cleanupTasks.length" class="p-12 text-center text-muted-foreground">
              <ClipboardList class="w-12 h-12 mx-auto mb-4 text-muted-foreground/50" />
              <p class="mb-2 text-lg font-medium">No cleanup tasks found</p>
              <p>No tasks match the current filter</p>
            </div>

            <div v-else>
              <div class="overflow-hidden border rounded-lg shadow-sm">
                <table class="w-full text-sm text-left">
                  <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-waste2way-dark/50 dark:text-gray-300">
                    <tr>
                      <th scope="col" class="px-6 py-3">Task ID</th>
                      <th scope="col" class="px-6 py-3">Location</th>
                      <th scope="col" class="px-6 py-3">Truck</th>
                      <th scope="col" class="px-6 py-3">Status</th>
                      <th scope="col" class="px-6 py-3">Created At</th>
                      <th scope="col" class="px-6 py-3">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="task in cleanupTasks" :key="task.id" class="bg-white border-b dark:bg-waste2way-dark/20 dark:border-gray-700">
                      <td class="px-6 py-4">#{{ task.id }}</td>
                      <td class="px-6 py-4">
                        {{ getAddressFromCoords(task.latitude, task.longitude) }}
                      </td>
                      <td class="px-6 py-4">{{ task.truck.truckNumber }}</td>
                      <td class="px-6 py-4">
                        <span 
                          class="px-2.5 py-0.5 text-xs font-medium rounded-full" 
                          :class="getStatusClass(task.status)"
                        >
                          {{ task.status }}
                        </span>
                      </td>
                      <td class="px-6 py-4">{{ formatDate(task.createdAt) }}</td>
                      <td class="px-6 py-4">
                        <div class="flex space-x-2">
                          <button
                            v-if="task.status === 'ASSIGNED'"
                            @click="updateTaskStatus(task.id, 'IN_PROGRESS')"
                            class="px-3 py-1 text-xs font-medium rounded-full text-white bg-blue-500 hover:bg-blue-600"
                          >
                            Start
                          </button>
                          <button
                            v-if="task.status === 'IN_PROGRESS'"
                            @click="openCompleteTaskModal(task)"
                            class="px-3 py-1 text-xs font-medium rounded-full text-white bg-green-500 hover:bg-green-600"
                          >
                            Complete
                          </button>
                          <button
                            v-if="task.status !== 'COMPLETED'"
                            @click="viewTaskDetails(task)"
                            class="px-3 py-1 text-xs font-medium rounded-full text-waste2way-teal bg-waste2way-teal/10 hover:bg-waste2way-teal/20"
                          >
                            View
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Trucks Tab -->
          <div v-if="activeTab === 'trucks'" class="space-y-6">
            <div class="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
              <h2 class="text-xl font-bold">Fleet Management</h2>
              <button
                @click="openAddTruckModal"
                class="flex items-center px-4 py-2 space-x-2 text-sm font-medium rounded-lg bg-waste2way-teal text-white"
              >
                <PlusCircle class="w-4 h-4 mr-2" />
                Add Truck
              </button>
            </div>

            <div v-if="trucksLoading" class="flex items-center justify-center py-12">
              <div class="w-12 h-12 border-b-2 border-waste2way-teal rounded-full animate-spin"></div>
            </div>

            <div v-else-if="!trucks.length" class="p-12 text-center text-muted-foreground">
              <Truck class="w-12 h-12 mx-auto mb-4 text-muted-foreground/50" />
              <p class="mb-2 text-lg font-medium">No trucks available</p>
              <p>Add trucks to your fleet to manage cleanup operations</p>
            </div>

            <div v-else>
              <div class="overflow-hidden border rounded-lg shadow-sm">
                <table class="w-full text-sm text-left">
                  <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-waste2way-dark/50 dark:text-gray-300">
                    <tr>
                      <th scope="col" class="px-6 py-3">Truck Number</th>
                      <th scope="col" class="px-6 py-3">Status</th>
                      <th scope="col" class="px-6 py-3">Current Task</th>
                      <th scope="col" class="px-6 py-3">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="truck in trucks" :key="truck.id" class="bg-white border-b dark:bg-waste2way-dark/20 dark:border-gray-700">
                      <td class="px-6 py-4">{{ truck.truckNumber }}</td>
                      <td class="px-6 py-4">
                        <span 
                          class="px-2.5 py-0.5 text-xs font-medium rounded-full" 
                          :class="getTruckStatusClass(truck.status)"
                        >
                          {{ truck.status }}
                        </span>
                      </td>
                      <td class="px-6 py-4">
                        <span v-if="getTruckTask(truck.id)">
                          Task #{{ getTruckTask(truck.id) }}
                        </span>
                        <span v-else class="text-muted-foreground">No active task</span>
                      </td>
                      <td class="px-6 py-4">
                        <div class="flex space-x-2">
                          <button
                            v-if="truck.status === 'AVAILABLE'"
                            @click="setTruckMaintenance(truck.id)"
                            class="px-3 py-1 text-xs font-medium rounded-full text-amber-700 bg-amber-100 hover:bg-amber-200"
                          >
                            Set to Maintenance
                          </button>
                          <button
                            v-if="truck.status === 'MAINTENANCE'"
                            @click="setTruckAvailable(truck.id)"
                            class="px-3 py-1 text-xs font-medium rounded-full text-green-700 bg-green-100 hover:bg-green-200"
                          >
                            Set to Available
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Materials Tab -->
          <div v-if="activeTab === 'materials'" class="space-y-6">
            <h2 class="text-xl font-bold">Recycling Materials</h2>

            <div v-if="materialsLoading" class="flex items-center justify-center py-12">
              <div class="w-12 h-12 border-b-2 border-waste2way-teal rounded-full animate-spin"></div>
            </div>

            <div v-else>
              <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <div class="p-6 rounded-lg glass-card dark:glass-card-dark">
                  <h3 class="mb-4 text-lg font-medium">Material Distribution</h3>
                  <div class="h-64">
                    <canvas ref="materialChart"></canvas>
                  </div>
                </div>

                <div class="p-6 rounded-lg glass-card dark:glass-card-dark">
                  <h3 class="mb-4 text-lg font-medium">Recent Materials Collected</h3>
                  <div class="overflow-auto max-h-64">
                    <table class="w-full text-sm text-left">
                      <thead class="text-xs text-gray-700 sticky top-0 bg-white dark:bg-waste2way-dark/50 dark:text-gray-300">
                        <tr>
                          <th scope="col" class="px-4 py-2">Date</th>
                          <th scope="col" class="px-4 py-2">Plastic</th>
                          <th scope="col" class="px-4 py-2">Paper</th>
                          <th scope="col" class="px-4 py-2">Glass</th>
                          <th scope="col" class="px-4 py-2">Metal</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-for="material in recyclingMaterials" :key="material.id" class="border-b dark:border-gray-700">
                          <td class="px-4 py-2">{{ formatDate(material.createdAt) }}</td>
                          <td class="px-4 py-2">{{ material.plasticWeight }}kg</td>
                          <td class="px-4 py-2">{{ material.paperWeight }}kg</td>
                          <td class="px-4 py-2">{{ material.glassWeight }}kg</td>
                          <td class="px-4 py-2">{{ material.metalWeight }}kg</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>

              <div class="grid grid-cols-1 gap-6 mt-6 md:grid-cols-3">
                <div class="p-6 rounded-lg glass-card dark:glass-card-dark">
                  <h3 class="mb-2 text-sm font-medium text-muted-foreground">Total Plastic Collected</h3>
                  <p class="text-2xl font-bold">{{ getTotalMaterial('plastic') }}kg</p>
                  <div class="w-full h-2 mt-2 rounded-full bg-muted">
                    <div
                      class="h-2 rounded-full bg-waste2way-teal"
                      :style="{ width: `${getMaterialPercentage('plastic')}%` }"
                    ></div>
                  </div>
                </div>

                <div class="p-6 rounded-lg glass-card dark:glass-card-dark">
                  <h3 class="mb-2 text-sm font-medium text-muted-foreground">Material Destination Types</h3>
                  <div class="flex flex-wrap gap-2 mt-2">
                    <div 
                      v-for="(count, destination) in destinationCounts" 
                      :key="destination"
                      class="px-2 py-1 text-xs rounded-full bg-waste2way-teal/10 text-waste2way-teal"
                    >
                      {{ formatDestination(destination) }}: {{ count }}
                    </div>
                  </div>
                </div>

                <div class="p-6 rounded-lg glass-card dark:glass-card-dark">
                  <h3 class="mb-2 text-sm font-medium text-muted-foreground">Environmental Impact</h3>
                  <p class="text-lg font-medium">{{ calculateCO2Reduction() }}kg CO₂ saved</p>
                  <p class="text-sm text-muted-foreground">Based on recycled materials</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Add Truck Modal -->
    <Modal :show="showAddTruckModal" @close="showAddTruckModal = false">
      <div class="p-6">
        <h3 class="mb-4 text-lg font-medium">Add New Truck</h3>
        <div class="mb-4">
          <label class="block mb-2 text-sm font-medium">Truck Number</label>
          <input 
            v-model="newTruck.truckNumber"
            type="text" 
            class="w-full px-3 py-2 border rounded-lg"
            placeholder="Enter truck number or identifier"
          />
        </div>
        <div class="flex justify-end space-x-3">
          <button 
            @click="showAddTruckModal = false"
            class="px-4 py-2 text-sm font-medium border rounded-lg border-input bg-background hover:bg-accent hover:text-accent-foreground"
          >
            Cancel
          </button>
          <button 
            @click="addTruck"
            class="px-4 py-2 text-sm font-medium rounded-lg text-white bg-waste2way-teal hover:bg-waste2way-teal/90"
            :disabled="!newTruck.truckNumber"
          >
            Add Truck
          </button>
        </div>
      </div>
    </Modal>

    <!-- Complete Task Modal -->
    <Modal :show="showCompleteTaskModal" @close="showCompleteTaskModal = false">
      <div class="p-6">
        <h3 class="mb-4 text-lg font-medium">Complete Cleanup Task</h3>
        <p class="mb-4 text-sm text-muted-foreground">Record materials collected during this cleanup operation</p>
        
        <div class="grid grid-cols-2 gap-4 mb-4">
          <div>
            <label class="block mb-2 text-sm font-medium">Plastic Weight (kg)</label>
            <input 
              v-model="taskMaterialData.plasticWeight"
              type="number" 
              min="0"
              step="0.1"
              class="w-full px-3 py-2 border rounded-lg"
            />
          </div>
          <div>
            <label class="block mb-2 text-sm font-medium">Paper Weight (kg)</label>
            <input 
              v-model="taskMaterialData.paperWeight"
              type="number" 
              min="0"
              step="0.1"
              class="w-full px-3 py-2 border rounded-lg"
            />
          </div>
          <div>
            <label class="block mb-2 text-sm font-medium">Glass Weight (kg)</label>
            <input 
              v-model="taskMaterialData.glassWeight"
              type="number" 
              min="0"
              step="0.1"
              class="w-full px-3 py-2 border rounded-lg"
            />
          </div>
          <div>
            <label class="block mb-2 text-sm font-medium">Metal Weight (kg)</label>
            <input 
              v-model="taskMaterialData.metalWeight"
              type="number" 
              min="0"
              step="0.1"
              class="w-full px-3 py-2 border rounded-lg"
            />
          </div>
          <div>
            <label class="block mb-2 text-sm font-medium">Organic Weight (kg)</label>
            <input 
              v-model="taskMaterialData.organicWeight"
              type="number" 
              min="0"
              step="0.1"
              class="w-full px-3 py-2 border rounded-lg"
            />
          </div>
          <div>
            <label class="block mb-2 text-sm font-medium">Other Weight (kg)</label>
            <input 
              v-model="taskMaterialData.otherWeight"
              type="number" 
              min="0"
              step="0.1"
              class="w-full px-3 py-2 border rounded-lg"
            />
          </div>
        </div>

        <div class="mb-4">
          <label class="block mb-2 text-sm font-medium">Destination Type</label>
          <select 
            v-model="taskMaterialData.destinationType"
            class="w-full px-3 py-2 border rounded-lg"
          >
            <option value="RECYCLING_CENTER">Recycling Center</option>
            <option value="INFRASTRUCTURE">Infrastructure Projects</option>
            <option value="SCRAP_ARTISTS">Scrap Artists</option>
          </select>
        </div>
        
        <div class="flex justify-end space-x-3">
          <button 
            @click="showCompleteTaskModal = false"
            class="px-4 py-2 text-sm font-medium border rounded-lg border-input bg-background hover:bg-accent hover:text-accent-foreground"
          >
            Cancel
          </button>
          <button 
            @click="completeTask"
            class="px-4 py-2 text-sm font-medium rounded-lg text-white bg-green-500 hover:bg-green-600"
          >
            Complete Task
          </button>
        </div>
      </div>
    </Modal>

    <!-- Task Detail Modal -->
    <Modal :show="showTaskDetailModal" @close="showTaskDetailModal = false">
      <div class="p-6">
        <h3 class="mb-4 text-lg font-medium">Task Details</h3>
        <div v-if="selectedTask" class="space-y-4">
          <div class="p-4 rounded-lg bg-muted">
            <div class="grid grid-cols-2 gap-4">
              <div>
                <p class="text-sm text-muted-foreground">Task ID</p>
                <p class="font-medium">#{{ selectedTask.id }}</p>
              </div>
              <div>
                <p class="text-sm text-muted-foreground">Status</p>
                <p>
                  <span 
                    class="px-2.5 py-0.5 text-xs font-medium rounded-full" 
                    :class="getStatusClass(selectedTask.status)"
                  >
                    {{ selectedTask.status }}
                  </span>
                </p>
              </div>
              <div>
                <p class="text-sm text-muted-foreground">Location</p>
                <p class="font-medium">{{ getAddressFromCoords(selectedTask.latitude, selectedTask.longitude) }}</p>
              </div>
              <div>
                <p class="text-sm text-muted-foreground">Truck</p>
                <p class="font-medium">{{ selectedTask.truck.truckNumber }}</p>
              </div>
              <div>
                <p class="text-sm text-muted-foreground">Report Count</p>
                <p class="font-medium">{{ selectedTask.reportCount }}</p>
              </div>
              <div>
                <p class="text-sm text-muted-foreground">Average Severity</p>
                <p class="font-medium">{{ selectedTask.avgSeverity.toFixed(1) }}</p>
              </div>
              <div>
                <p class="text-sm text-muted-foreground">Created At</p>
                <p class="font-medium">{{ formatDate(selectedTask.createdAt) }}</p>
              </div>
            </div>
          </div>

          <div v-if="selectedTask.reportIds?.length">
            <h4 class="mb-2 text-sm font-medium">Related Reports</h4>
            <ul class="pl-5 space-y-1 list-disc">
              <li v-for="reportId in selectedTask.reportIds" :key="reportId" class="text-sm">
                Report #{{ reportId }}
              </li>
            </ul>
          </div>

          <div class="flex justify-end">
            <button 
              @click="showTaskDetailModal = false"
              class="px-4 py-2 text-sm font-medium border rounded-lg border-input bg-background hover:bg-accent hover:text-accent-foreground"
            >
              Close
            </button>
          </div>
        </div>
      </div>
    </Modal>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue';
import { 
  AlertTriangle, ClipboardCheck, Truck, RefreshCw, Radar, Trash2, 
  ClipboardList, PlusCircle, Map, BarChart3
} from 'lucide-vue-next';
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);

const { get, post, put } = useApi();

// Tabs
const tabs = [
  { id: 'hotspots', label: 'Hotspots', icon: Map },
  { id: 'tasks', label: 'Cleanup Tasks', icon: ClipboardList },
  { id: 'trucks', label: 'Trucks', icon: Truck },
  { id: 'materials', label: 'Materials', icon: BarChart3 },
];
const activeTab = ref('hotspots');

// State
const isLoading = ref(false);
const tasksLoading = ref(false);
const trucksLoading = ref(false);
const materialsLoading = ref(false);
const isMonitoring = ref(false);
const criticalHotspots = ref([]);
const cleanupTasks = ref([]);
const trucks = ref([]);
const recyclingMaterials = ref([]);
const taskFilter = ref('all');
const criticalCount = ref(0);
const criticalChange = ref('8%');
const activeTasksCount = ref(0);
const availableTrucksCount = ref(0);

// Modal state
const showAddTruckModal = ref(false);
const showCompleteTaskModal = ref(false);
const showTaskDetailModal = ref(false);
const selectedTask = ref(null);
const newTruck = ref({ truckNumber: '' });
const taskMaterialData = ref({
  plasticWeight: 0,
  paperWeight: 0,
  glassWeight: 0,
  metalWeight: 0,
  organicWeight: 0,
  otherWeight: 0,
  destinationType: 'RECYCLING_CENTER'
});

// Chart refs
const materialChart = ref(null);
let chartInstance = null;

// Watch for tab changes to load data
watch(activeTab, (newTab) => {
  if (newTab === 'tasks') {
    fetchCleanupTasks();
  } else if (newTab === 'trucks') {
    fetchTrucks();
  } else if (newTab === 'materials') {
    fetchRecyclingMaterials();
  }
});

// Watch task filter changes
watch(taskFilter, () => {
  fetchCleanupTasks();
});

// Methods
async function monitorHotspots() {
  isMonitoring.value = true;
  isLoading.value = true;
  
  try {
    const { data } = await post('/cleanup/monitor');
    await fetchCriticalHotspots();
    console.log('Monitoring result:', data);
  } catch (error) {
    console.error('Error monitoring hotspots:', error);
  } finally {
    isMonitoring.value = false;
    isLoading.value = false;
  }
}

async function fetchCriticalHotspots() {
  isLoading.value = true;
  
  try {
    const { data } = await get('/trash/hotspots');
    // Filter for critical hotspots (those with reportCount >= 5)
    criticalHotspots.value = data.filter(hotspot => hotspot.reportCount >= 5);
    criticalCount.value = criticalHotspots.value.length;
  } catch (error) {
    console.error('Error fetching hotspots:', error);
  } finally {
    isLoading.value = false;
  }
}

async function fetchCleanupTasks() {
  tasksLoading.value = true;
  
  try {
    let endpoint = '/cleanup/tasks';
    if (taskFilter.value !== 'all') {
      endpoint += `?status=${taskFilter.value}`;
    }
    
    const { data } = await get(endpoint);
    cleanupTasks.value = data;
    activeTasksCount.value = data.filter(task => 
      task.status === 'ASSIGNED' || task.status === 'IN_PROGRESS'
    ).length;
  } catch (error) {
    console.error('Error fetching cleanup tasks:', error);
  } finally {
    tasksLoading.value = false;
  }
}

async function fetchTrucks() {
  trucksLoading.value = true;
  
  try {
    const { data } = await get('/trucks');
    trucks.value = data;
    availableTrucksCount.value = data.filter(truck => truck.status === 'AVAILABLE').length;
  } catch (error) {
    console.error('Error fetching trucks:', error);
  } finally {
    trucksLoading.value = false;
  }
}

async function fetchRecyclingMaterials() {
  materialsLoading.value = true;
  
  try {
    const { data } = await get('/materials');
    recyclingMaterials.value = data;
    renderMaterialChart();
  } catch (error) {
    console.error('Error fetching recycling materials:', error);
  } finally {
    materialsLoading.value = false;
  }
}

async function assignCleanupTask(hotspot) {
  try {
    await post('/cleanup/tasks', {
      latitude: hotspot.latGroup,
      longitude: hotspot.lngGroup,
      reportIds: hotspot.reports.map(r => r.id),
      reportCount: hotspot.reportCount,
      avgSeverity: hotspot.avgSeverity
    });
    
    // Refresh data
    await fetchCriticalHotspots();
    await fetchCleanupTasks();
    await fetchTrucks();
  } catch (error) {
    console.error('Error assigning cleanup task:', error);
  }
}

async function updateTaskStatus(taskId, status) {
  try {
    await put(`/cleanup/tasks/${taskId}`, { status });
    await fetchCleanupTasks();
  } catch (error) {
    console.error('Error updating task status:', error);
  }
}

function openCompleteTaskModal(task) {
  selectedTask.value = task;
  showCompleteTaskModal.value = true;
  
  // Reset material data
  taskMaterialData.value = {
    plasticWeight: 0,
    paperWeight: 0,
    glassWeight: 0,
    metalWeight: 0,
    organicWeight: 0,
    otherWeight: 0,
    destinationType: 'RECYCLING_CENTER'
  };
}

async function completeTask() {
  if (!selectedTask.value) return;
  
  try {
    await put(`/cleanup/tasks/${selectedTask.value.id}`, { 
      status: 'COMPLETED',
      materialData: taskMaterialData.value
    });
    
    showCompleteTaskModal.value = false;
    await fetchCleanupTasks();
    await fetchTrucks();
    
    if (activeTab.value === 'materials') {
      await fetchRecyclingMaterials();
    }
  } catch (error) {
    console.error('Error completing task:', error);
  }
}

function viewTaskDetails(task) {
  selectedTask.value = task;
  showTaskDetailModal.value = true;
}

function openAddTruckModal() {
  newTruck.value = { truckNumber: '' };
  showAddTruckModal.value = true;
}

async function addTruck() {
  if (!newTruck.value.truckNumber) return;
  
  try {
    await post('/trucks', newTruck.value);
    showAddTruckModal.value = false;
    await fetchTrucks();
  } catch (error) {
    console.error('Error adding truck:', error);
  }
}

async function setTruckMaintenance(truckId) {
  try {
    await put(`/trucks/${truckId}`, { status: 'MAINTENANCE' });
    await fetchTrucks();
  } catch (error) {
    console.error('Error setting truck to maintenance:', error);
  }
}

async function setTruckAvailable(truckId) {
  try {
    await put(`/trucks/${truckId}`, { status: 'AVAILABLE' });
    await fetchTrucks();
  } catch (error) {
    console.error('Error setting truck to available:', error);
  }
}

function renderMaterialChart() {
  if (chartInstance) {
    chartInstance.destroy();
  }
  
  if (!materialChart.value) return;
  
  const ctx = materialChart.value.getContext('2d');
  
  // Calculate totals
  const totalPlastic = getTotalMaterial('plastic');
  const totalPaper = getTotalMaterial('paper');
  const totalGlass = getTotalMaterial('glass');
  const totalMetal = getTotalMaterial('metal');
  const totalOrganic = getTotalMaterial('organic');
  const totalOther = getTotalMaterial('other');
  
  chartInstance = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: ['Plastic', 'Paper', 'Glass', 'Metal', 'Organic', 'Other'],
      datasets: [{
        data: [totalPlastic, totalPaper, totalGlass, totalMetal, totalOrganic, totalOther],
        backgroundColor: [
          '#2A9D8F', // waste2way-teal
          '#48CAE4', // waste2way-blue
          '#57CC99', // waste2way-green
          '#F4845F', // waste2way-coral
          '#023E8A', // waste2way-navy
          '#6