/* youtube-dl-qt is Free Software: You can use, study share
 * and improve it at your will. Specifically you can redistribute
 * and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 * 
 * The original author of this code : Robin de Rooij (https://github.com/rrooij)
 * The original repository of this code : https://github.com/rrooij/youtube-dl-qt 
 */

#ifndef MEDIAFORMAT_H
#define MEDIAFORMAT_H

#include <QObject>
#include <QString>
#include <QStringList>

class MediaFormat : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList formatId READ getFormatId WRITE setFormatId NOTIFY formatIdChanged)
    Q_PROPERTY(QStringList format READ getFormat WRITE setFormat NOTIFY formatChanged)
    Q_PROPERTY(QStringList extension READ getExtension WRITE setExtension NOTIFY extensionChanged)
    Q_PROPERTY(QStringList resolution READ getResolution WRITE setResolution NOTIFY resolutionChanged)
    Q_PROPERTY(QStringList quality READ getQuality WRITE setQuality NOTIFY qualityChanged)
    Q_PROPERTY(QStringList note READ getNote WRITE setNote NOTIFY noteChanged)
    Q_PROPERTY(QStringList acodec READ getAcodec WRITE setAcodec NOTIFY acodecChanged)
    Q_PROPERTY(QStringList vcodec READ getVcodec WRITE setVcodec NOTIFY vcodecChanged)

public:
    explicit MediaFormat(QObject *parent = nullptr);
    QStringList getFormatId() const;
    void setFormatId(const QStringList &value);
    void setFormatIdItem(QString value);

    QStringList getExtension() const;
    void setExtension(const QStringList &value);
    void setExtensionItem(QString value);

    QStringList getResolution() const;
    void setResolution(const QStringList &value);
    void setResolutionItem(QString value);

    QStringList getQuality() const;
    void setQuality(const QStringList &value);
    void setQualityItem(QString value);

    QStringList getNote() const;
    void setNote(const QStringList &value);
    void setNoteItem(QString value);

    QStringList getFormat() const;
    void setFormat(const QStringList &value);
    void setFormatItem(QString value);

    QStringList getAcodec() const;
    void setAcodec(const QStringList &value);
    void setAcodecItem(QString value);

    QStringList getVcodec() const;
    void setVcodec(const QStringList &value);
    void setVcodecItem(QString value);

signals:
    void formatIdChanged(const QStringList &value);
    void formatChanged(const QStringList &value);
    void extensionChanged(const QStringList &value);
    void resolutionChanged(const QStringList &value);
    void qualityChanged(const QStringList &value);
    void noteChanged(const QStringList &value);
    void acodecChanged(const QStringList &value);
    void vcodecChanged(const QStringList &value);

private:
    QStringList m_formatId;
    QStringList m_format;
    QStringList m_extension;
    QStringList m_resolution;
    QStringList m_quality;
    QStringList m_note;
    QStringList m_acodec;
    QStringList m_vcodec;
};

#endif // MEDIAFORMAT_H
