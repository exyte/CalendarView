//
//  LocalCalendarsStorage.swift
//  CalendarView
//
//  Created by Alisa Mylnikova on 01.07.2025.
//

import Foundation
import SwiftUI

public actor CodableStore<T: Codable> {
    private let fileManager = FileManager.default
    private let baseURL: URL
    private var cache: [T] = []
    private let folderName: String

    public init(folderName: String? = nil) {
        self.folderName = folderName ?? String(describing: T.self)
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.baseURL = docs.appendingPathComponent(self.folderName)
        do {
            try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
        } catch {
            print(error)
        }
    }

    private var defaultURL: URL {
        baseURL.appendingPathComponent("data.json")
    }

    public func save(_ values: [T]) async throws {
        let data = try JSONEncoder().encode(values)
        cache = values
        try data.write(to: defaultURL, options: .atomic)
    }

    public func load() async throws -> [T] {
        if !cache.isEmpty {
            return cache
        }
        guard fileManager.fileExists(atPath: defaultURL.path) else { return [] }
        let data = try Data(contentsOf: defaultURL)
        let decoded = try JSONDecoder().decode([T].self, from: data)
        cache = decoded
        return decoded
    }

    public func delete() async throws {
        try? fileManager.removeItem(at: defaultURL)
        cache.removeAll()
    }
}

// MARK: - 2. EventsStore

public final actor CalendarEntityStore<T: CalendarEntity> {
    private let fileManager = FileManager.default
    private let calendar = Calendar(identifier: .gregorian)
    private let baseURL: URL
    private var cache: [String: [T]] = [:] // key = "calendarID-YYYY-MM"

    public init(folderName: String = "Events") {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.baseURL = docs.appendingPathComponent(folderName)
        do {
            try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
        } catch {
            print("Failed to create base directory: \(error)")
        }
    }

    private func monthKey(for date: Date) -> String {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", comps.year ?? 0, comps.month ?? 0)
    }

    private func fileURL(calendarID: String, monthKey: String) -> URL {
        baseURL
            .appendingPathComponent(String(describing: T.self))
            .appendingPathComponent(calendarID)
            .appendingPathComponent("\(monthKey).json")
    }

    private func loadChunkFromDisk(calendarID: String, month: Date) async throws -> [T] {
        let path = fileURL(calendarID: calendarID, monthKey: monthKey(for: month))
        guard fileManager.fileExists(atPath: path.path) else {
            return []
        }
        let data = try Data(contentsOf: path)
        let decoded = try JSONDecoder().decode([T].self, from: data)
        return decoded
    }

    private func updateCache(key: String, with events: [T]) {
        cache[key] = events
    }

    private func getChunk(calendarID: String, month: Date) async throws -> [T] {
        let key = "\(calendarID)-\(monthKey(for: month))"

        if let cached = cache[key] {
            return cached
        }

        let events = try await loadChunkFromDisk(calendarID: calendarID, month: month)
        // update cache synchronously on actor without awaiting anything else
        updateCache(key: key, with: events)
        return events
    }

    private func saveChunk(_ events: [T], calendarID: String, month: Date) async throws {
        let key = "\(calendarID)-\(monthKey(for: month))"
        // update cache first, synchronously
        updateCache(key: key, with: events)

        // Then write to disk (async)
        let data = try JSONEncoder().encode(events)
        let path = fileURL(calendarID: calendarID, monthKey: monthKey(for: month))
        try fileManager.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: path, options: .atomic)
    }

    public func add(_ event: T) async throws {
        let month = event.startDate
        let key = "\(event.calendarID)-\(monthKey(for: month))"

        var chunk = cache[key]
        if chunk == nil {
            chunk = try await loadChunkFromDisk(calendarID: event.calendarID, month: month)
        }

        chunk?.append(event)
        if let chunk = chunk {
            try await saveChunk(chunk, calendarID: event.calendarID, month: month)
        }
    }

    /// Updates an existing entity by ID using its original startDate to locate the chunk.
    /// If the new startDate falls in a different month, removes from the old chunk
    /// and inserts into the new one.
    public func update(_ updated: T, oldCalendarID: String, oldStartDate: Date) async throws {
        let oldMonth = monthKey(for: oldStartDate)
        let newMonth = monthKey(for: updated.startDate)
        if oldMonth == newMonth, oldCalendarID == updated.calendarID {
            var chunk = try await getChunk(calendarID: updated.calendarID, month: oldStartDate)
            guard let index = chunk.firstIndex(where: { $0.id == updated.id }) else { return }
            chunk[index] = updated
            try await saveChunk(chunk, calendarID: updated.calendarID, month: oldStartDate)
            return
        }
        var oldChunk = try await getChunk(calendarID: oldCalendarID, month: oldStartDate)
        oldChunk.removeAll { $0.id == updated.id }
        try await saveChunk(oldChunk, calendarID: oldCalendarID, month: oldStartDate)
        var newChunk = try await getChunk(calendarID: updated.calendarID, month: updated.startDate)
        newChunk.append(updated)
        try await saveChunk(newChunk, calendarID: updated.calendarID, month: updated.startDate)
    }

    public func delete(id: String, calendarID: String, from date: Date) async throws {
        var chunk = try await getChunk(calendarID: calendarID, month: date)
        chunk.removeAll { $0.id == id }
        try await saveChunk(chunk, calendarID: calendarID, month: date)
    }

    public func events(from startDate: Date, to endDate: Date, calendarIDs: [String]) async throws -> [T] {
        var result: [T] = []
        for calendarID in calendarIDs {
            var current = calendar.date(from: calendar.dateComponents([.year, .month], from: startDate))!
            let end = calendar.date(from: calendar.dateComponents([.year, .month], from: endDate))!
            while current <= end {
                let key = "\(calendarID)-\(monthKey(for: current))"

                var chunk = cache[key]
                if chunk == nil {
                    chunk = try await loadChunkFromDisk(calendarID: calendarID, month: current)
                }
                guard let chunk else { break }
                updateCache(key: key, with: chunk)

                let filtered = chunk.filter { $0.startDate >= startDate && $0.startDate <= endDate }
                result += filtered
                current = calendar.date(byAdding: .month, value: 1, to: current)!
            }
        }
        return result
    }
}

